defmodule StreamCore.Users.Follower do
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias StreamCore.Repo
  alias StreamCore.Users.Follower
  alias StreamCore.Users.User

  schema "followers" do
    belongs_to(:streamer, User, foreign_key: :streamer_id, references: :id)
    belongs_to(:follower, User, foreign_key: :follower_id, references: :id)

    timestamps()
  end

  def changeset(follower, attrs \\ %{}) do
    follower
    |> cast(attrs, [:follower_id, :streamer_id])
    |> foreign_key_constraint(:follower_id)
    |> foreign_key_constraint(:streamer_id)
    |> validate_required([:follower_id, :streamer_id])
    |> unique_constraint([:follower_id, :streamer_id])
  end

  @doc """
  Allows Follows Repo to be queried by follower_id and streamer_id
  """
  def query_by_params(params, preloads) do
    from(follower in Follower)
    |> Repo.with_filter(params, &handle_query_filters/2)
    |> preload(^preloads)
  end

  defp handle_query_filters({_, nil}, query), do: query

  defp handle_query_filters({:follower_id, data}, query),
    do: where(query, [follower], follower.follower_id == ^data)

  defp handle_query_filters({:streamer_id, data}, query),
    do: where(query, [follower], follower.streamer_id == ^data)
end
