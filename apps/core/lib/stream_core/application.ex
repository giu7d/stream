defmodule StreamCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      StreamCoreWeb.Telemetry,
      # Start the Ecto repository
      StreamCore.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: StreamCore.PubSub},
      # Start Finch
      {Finch, name: StreamCore.Finch},
      # Start the Endpoint (http/https)
      StreamCoreWeb.Endpoint
      # Start a worker by calling: StreamCore.Worker.start_link(arg)
      # {StreamCore.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StreamCore.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StreamCoreWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
