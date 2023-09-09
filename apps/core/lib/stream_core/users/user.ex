defmodule StreamCore.Users.User do
  alias StreamCore.Users.Follower
  alias StreamCore.Repo
  alias StreamCore.Users.User

  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  schema "users" do
    field(:username, :string)
    field(:email, :string)
    field(:password, :string, virtual: true, redact: true)
    field(:hashed_password, :string, redact: true)
    field(:stream_key, :binary)

    many_to_many(:followers, User,
      join_through: Follower,
      join_keys: [streamer_id: :id, follower_id: :id]
    )

    many_to_many(:following, User,
      join_through: Follower,
      join_keys: [follower_id: :id, streamer_id: :id]
    )

    timestamps()
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :email, :password])
    |> validate_username(opts)
    |> validate_email(opts)
    |> validate_password(opts)
    |> generate_stream_key(opts)
  end

  @doc """
  A user changeset for validating login with username and password.
  """
  def login_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_username(validate_username: false)
    |> validate_password(opts)
  end

  @doc """
  A user changeset for updating username and email.

  It requires the username to change otherwise an error is added.
  """
  def update_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_username(opts)
    |> validate_email(opts)
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Generates the stream key on email confirmation
  """
  def generate_stream_key(user, _opts) do
    put_change(user, :stream_key, Ecto.UUID.bingenerate())
  end

  @doc """
  Verifies the password.
  """
  def valid_password?(%StreamCore.Users.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  defp validate_username(changeset, opts) do
    changeset
    |> validate_required([:username])
    |> validate_length(:username, min: 3, max: 20)
    |> unsafe_validate_unique_username(opts)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unsafe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 72)
    # Examples of additional password validation:
    # |> validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> unsafe_hash_password(opts)
  end

  defp unsafe_validate_unique_username(changeset, opts) do
    if Keyword.get(opts, :validate_username, true) do
      changeset
      |> unsafe_validate_unique(:username, StreamCore.Repo)
      |> unique_constraint(:username)
    else
      changeset
    end
  end

  defp unsafe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, StreamCore.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp unsafe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> validate_length(:password, max: 72, count: :bytes)
      # Hashing could be done with `Ecto.Changeset.prepare_changes/2`, but that
      # would keep the database transaction open longer and hurt performance.
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  Allows User Repo to be queried by id, email, or username
  """
  def query_by_params(params, preloads) do
    from(user in User)
    |> Repo.with_filter(params, &handle_query_filters/2)
    |> preload(^preloads)
  end

  defp handle_query_filters({_, nil}, query), do: query

  defp handle_query_filters({:id, data}, query), do: where(query, [user], user.id == ^data)

  defp handle_query_filters({:email, data}, query), do: where(query, [user], user.email == ^data)

  defp handle_query_filters({:username, data}, query),
    do: where(query, [user], user.username == ^data)
end
