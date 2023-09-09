defmodule StreamCore.LiveStream do
  use Membrane.Pipeline

  alias StreamCore.LiveStream.Stream
  alias Membrane.HTTPAdaptiveStream.{Sink, SinkBin}
  alias Membrane.RTMP.SourceBin

  @stream_output_dir Application.compile_env(:stream_core, :stream_output_dir, "output")

  @impl true
  def handle_init(_ctx, socket: socket, validator: validator, use_ssl?: use_ssl?) do
    source_bin = %SourceBin{
      socket: socket,
      validator: validator,
      use_ssl?: use_ssl?
    }

    sink_bin = %SinkBin{
      manifest_module: Membrane.HTTPAdaptiveStream.HLS,
      target_window_duration: :infinity,
      mode: :live,
      hls_mode: :muxed_av,
      persist?: false,
      storage: %StreamCore.FileStorage{
        location: @stream_output_dir,
        socket: socket
      }
    }

    segment_duration = %Sink.SegmentDuration{
      min: 2 |> Membrane.Time.seconds(),
      target: 4 |> Membrane.Time.seconds()
    }

    audio_pipeline =
      :src
      |> get_child()
      |> via_out(:audio)
      |> via_in(
        Pad.ref(:input, :audio),
        options: [encoding: :AAC, segment_duration: segment_duration]
      )
      |> get_child(:sink)

    video_pipeline =
      :src
      |> get_child()
      |> via_out(:video)
      |> via_in(
        Pad.ref(:input, :video),
        options: [encoding: :H264, segment_duration: segment_duration]
      )
      |> get_child(:sink)

    spec = [
      child(:src, source_bin),
      child(:sink, sink_bin),
      audio_pipeline,
      video_pipeline
    ]

    {[spec: spec, playback: :playing], %{socket: socket}}
  end

  # Once the source initializes, we grant it the control over the tcp socket
  @impl true
  def handle_child_notification(
        {:socket_control_needed, _socket, _source} = notification,
        :src,
        _ctx,
        state
      ) do
    send(self(), notification)
    {[], state}
  end

  def handle_child_notification(notification, _child, _ctx, state)
      when notification in [:end_of_stream, :socket_closed, :unexpected_socket_closed] do
    Membrane.Pipeline.terminate(self())
    {[], state}
  end

  def handle_child_notification(_notification, _child, _ctx, state) do
    {[], state}
  end

  @impl true
  def handle_info({:socket_control_needed, socket, source} = notification, _ctx, state) do
    case SourceBin.pass_control(socket, source) do
      :ok ->
        nil

      {:error, :not_owner} ->
        Process.send_after(self(), notification, 200)

      {:error, :closed} ->
        Membrane.Pipeline.terminate(self())
    end

    {[], state}
  end

  # The rest of the module is used for self-termination of the pipeline after processing finishes
  @impl true
  def handle_element_end_of_stream(:sink, _pad, _ctx, state) do
    {[terminate: :shutdown], state}
  end

  @impl true
  def handle_element_end_of_stream(_child, _pad, _ctx, state) do
    {[], state}
  end

  @impl true
  def handle_terminate_request(_ctx, state) do
    Agent.update(
      StreamCore.SocketAgent,
      fn sockets ->
        %{user: user} = Map.get(sockets, state.socket)

        StreamCore.FileStorage.remove_output_folder(user, state)

        Map.delete(sockets, state.socket)
      end
    )

    {[], state}
  end

  @spec list_live_streams :: any
  def list_live_streams() do
    Agent.get(
      StreamCore.SocketAgent,
      fn sockets ->
        Map.values(sockets)
      end
    )
  end

  def find_live_stream(username: username) do
    list_live_streams()
    |> Enum.find(fn live_stream -> live_stream.user.username == username end)
    |> case do
      nil -> %Stream{}
      stream -> stream
    end
  end

  def find_live_stream(socket: socket) do
    case Agent.get(StreamCore.SocketAgent, fn sockets -> sockets[socket] end) do
      nil -> %Stream{}
      x -> x
    end
  end

  def find_live_stream(_), do: nil

  def update_live_stream(nil, _), do: %Stream{}

  def update_live_stream(socket, update_fn) when is_function(update_fn, 1) do
    Agent.update(StreamCore.SocketAgent, fn sockets ->
      case sockets[socket] do
        nil ->
          sockets

        live_stream ->
          %{
            sockets
            | socket => Map.merge(live_stream, update_fn.(live_stream))
          }
      end
    end)

    live_stream = find_live_stream(socket: socket)

    case live_stream.user do
      nil ->
        nil

      user ->
        Phoenix.PubSub.broadcast(
          StreamCore.PubSub,
          "live:#{user.username}",
          live_stream
        )
    end

    live_stream
  end
end
