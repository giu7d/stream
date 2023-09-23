defmodule StreamCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias StreamCore.LiveStream
  alias Membrane.RTMP.Source.TcpServer, as: LiveStreamRTMPServer

  @port Application.compile_env(:stream_core, :stream_port, 9006)
  @host Application.compile_env(:stream_core, :stream_host, {127, 0, 0, 1})

  @impl true
  def start(_type, _args) do
    tcp_server_options = %LiveStreamRTMPServer{
      port: @port,
      listen_options: [
        :binary,
        packet: :raw,
        active: false,
        ip: @host
      ],
      socket_handler: &handle_tcp_socket/1
    }

    children = [
      # Start the Membrane TCP Server
      %{
        id: LiveStreamRTMPServer,
        start: {LiveStreamRTMPServer, :start_link, [tcp_server_options]}
      },
      # Start the Socket Agent
      %{
        id: StreamCore.SocketAgent,
        start: {Agent, :start_link, [fn -> %{} end, [name: StreamCore.SocketAgent]]}
      },
      # Start the Live Stream Monitor
      StreamCore.LiveStreamMonitor,
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

  defp handle_tcp_socket(socket) do
    Agent.update(StreamCore.SocketAgent, fn sockets ->
      Map.put(sockets, socket, %LiveStream.Stream{socket: socket})
    end)

    {:ok, _supervisor_pid, pipeline_pid} =
      LiveStream.start_link(
        socket: socket,
        validator: %LiveStream.StreamValidator{socket: socket},
        use_ssl?: false
      )

    {:ok, pipeline_pid}
  end
end
