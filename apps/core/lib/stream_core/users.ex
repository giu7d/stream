defmodule StreamCore.Users do
  alias StreamCore.Users.User
  alias StreamCore.Users.Follower
  alias StreamCore.Repo

  import Ecto.Query

  def create_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def list_users(), do: {:ok, Repo.all(User)}

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def find_user_by(params, preloads \\ []) do
    params
    |> user_base_query(preloads)
    |> Repo.one()
    |> case do
      %User{} = user -> {:ok, user}
      nil -> {:error, :not_found}
      _ -> {:error, :unexpected}
    end
  end

  defp user_base_query(params, preloads) do
    from(user in User)
    |> Repo.with_filter(params, &handle_filters/2)
    |> preload(^preloads)
  end

  defp handle_filters({_, nil}, query), do: query

  defp handle_filters({:id, data}, query), do: where(query, [user], user.id == ^data)

  defp handle_filters({:email, data}, query), do: where(query, [user], user.email == ^data)

  defp handle_filters({:username, data}, query), do: where(query, [user], user.username == ^data)

  def add_follower(%{follower_id: follower_id, streamer_id: streamer_id}) do
    %Follower{follower_id: follower_id, streamer_id: streamer_id}
    |> Follower.changeset()
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
end
