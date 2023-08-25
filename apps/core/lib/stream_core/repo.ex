defmodule StreamCore.Repo do
  use Ecto.Repo,
    otp_app: :stream_core,
    adapter: Ecto.Adapters.Postgres

  def with_filter(query, criteria, handle_filter) do
    Enum.reduce(criteria, query, handle_filter)
  end
end
