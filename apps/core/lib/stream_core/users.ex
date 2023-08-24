defmodule StreamCore.Users do
  alias StreamCore.Users.UserToken
  alias StreamCore.Users.User
  alias StreamCore.Users.Follower
  alias StreamCore.Repo

  import Ecto.Query

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

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

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

  def delete_user_session_token(token) do
    token
    |> UserToken.query_by_token_and_context("session")
    |> Repo.delete_all()
    |> case do
      {0, _} -> {:error, :not_found}
      {count, _} -> {:ok, count}
    end
  end

  def find_user_by_session_token(token, preloads \\ []) do
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
end
