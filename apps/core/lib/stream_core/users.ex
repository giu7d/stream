defmodule StreamCore.Users do
  alias StreamCore.Users.User
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
    query =
      params
      |> user_base_query(preloads)
      |> Repo.one()

    case query do
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
end
