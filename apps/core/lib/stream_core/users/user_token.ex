defmodule StreamCore.Users.UserToken do
  alias StreamCore.Users.UserToken
  alias StreamCore.Users.User

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @session_token_rand_size 32
  @session_token_validity_in_days 60

  schema "users_tokens" do
    field(:token, :binary)
    field(:context, :string)
    belongs_to(:user, User)

    timestamps(updated_at: false)
  end

  def changeset(user_token, attrs) do
    user_token
    |> cast(attrs, [:user_id, :context])
    |> foreign_key_constraint(:user_id)
    |> validate_required([:user_id, :context])
    |> generate_token()
  end

  def query_by_verified_session_token(token) do
    from(token in query_by_token_and_context(token, "session"),
      join: user in assoc(token, :user),
      where: token.inserted_at > ago(@session_token_validity_in_days, "day"),
      select: user
    )
  end

  def query_by_user_id(user, :all) do
    from(t in UserToken, where: t.user_id == ^user.id)
  end

  def query_by_token_and_context(token, context) do
    from(t in UserToken, where: t.token == ^token and t.context == ^context)
  end

  def query_by_user_and_contexts(user, [_ | _] = contexts) do
    from(t in UserToken, where: t.user_id == ^user.id and t.context in ^contexts)
  end

  defp generate_token(changeset) do
    token = :crypto.strong_rand_bytes(@session_token_rand_size)
    put_change(changeset, :token, token)
  end
end
