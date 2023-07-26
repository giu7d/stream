defmodule StreamCore.Repo do
  use Ecto.Repo,
    otp_app: :stream_core,
    adapter: Ecto.Adapters.Postgres
end
