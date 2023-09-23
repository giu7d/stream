defmodule StreamCore.Users do
  alias StreamCore.Users.UserToken
  alias StreamCore.Users.User
  alias StreamCore.Users.Follower
  alias StreamCore.Repo

  #
  # Users
  #
  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs \\ %{}) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def update_user_password(%User{} = user, password, attrs) do
    changeset =
      user
      |> User.password_changeset(attrs)
      |> User.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Repo.transaction()
    |> case do
      {:ok, %{user: user}} -> {:ok, user}
      {:error, :user, changeset, _} -> {:error, changeset}
    end
  end

  def list_users(), do: {:ok, Repo.all(User)}

  def delete_user(%User{} = user), do: Repo.delete(user)

  def find_user(search_params, preloads \\ []) do
    search_params
    |> User.query_by_params(preloads)
    |> Repo.one()
    |> case do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
      _ -> {:error, :unexpected}
    end
  end

  def find_user_with_password(username, password)
      when is_binary(username) and is_binary(password) do
    user = Repo.get_by(User, username: username)

    user
    |> User.valid_password?(password)
    |> case do
      true -> {:ok, user}
      _ -> {:error, :unauthorized}
    end
  end

  def find_user_with_password(_, _), do: {:error, :not_found}

  #
  # Followers
  #
  def add_follower(%{follower_id: follower_id, streamer_id: streamer_id}) do
    %Follower{}
    |> Follower.changeset(%{
      follower_id: follower_id,
      streamer_id: streamer_id
    })
    |> Repo.insert()
  end

  def remove_follower(%{follower_id: follower_id, streamer_id: streamer_id}) do
    Follower
    |> Repo.get_by(follower_id: follower_id, streamer_id: streamer_id)
    |> case do
      %Follower{} = follower -> Repo.delete(follower)
      _ -> {:error, :not_found}
    end
  end

  def toggle_follower(%{follower_id: _, streamer_id: _} = params) do
    Follower
    |> Repo.get_by(params)
    |> case do
      %Follower{} -> remove_follower(params)
      _ -> add_follower(params)
    end
  end

  def is_user_following?(%{follower_id: _, streamer_id: _} = params) do
    Follower
    |> Repo.get_by(params)
    |> case do
      %Follower{} -> true
      _ -> false
    end
  end

  def is_user_following?(_), do: false

  def find_user_followings(user_id, preloads \\ []) do
    %{follower_id: user_id}
    |> Follower.query_by_params(preloads)
    |> Repo.all()
    |> case do
      [%Follower{}] = followings -> {:ok, followings}
      nil -> {:error, :not_found}
      _ -> {:error, :unexpected}
    end
  end

  #
  # User Session Tokens
  #
  def create_user_session_token(%User{} = user) do
    %UserToken{}
    |> UserToken.changeset(%{
      user_id: user.id,
      context: "session"
    })
    |> Repo.insert()
  end

  def delete_user_session_token(token) when is_binary(token) do
    {count, _} =
      token
      |> UserToken.query_by_token_and_context("session")
      |> Repo.delete_all()

    {:ok, count}
  end

  def delete_user_session_token(_), do: {:error, :bad_request}

  def find_user_by_session_token(token), do: find_user_by_session_token(token, [])

  def find_user_by_session_token(token, preloads) when is_binary(token) do
    token
    |> UserToken.query_by_verified_session_token()
    |> Repo.one()
    |> Repo.preload(preloads)
    |> case do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
      _ -> {:error, :unexpected}
    end
  end

  def find_user_by_session_token(_, _), do: {:error, :bad_request}
end
