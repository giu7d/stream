defmodule StreamCore.LiveStream do
  use Membrane.Pipeline

  alias StreamCore.LiveStream
  alias Membrane.HTTPAdaptiveStream.{Sink, SinkBin}
  alias Membrane.RTMP.SourceBin

  @required_keys ~w()a
  @optional_keys ~w(socket)a
  @default_keys [is_live?: false, viewer_count: 0]

  defstruct(@required_keys ++ @optional_keys ++ @default_keys)

  @type t :: %__MODULE__{
          viewer_count: non_neg_integer(),
          socket: port(),
          is_live?: boolean()
        }

  @stream_output_dir Application.compile_env(:stream_core, :stream_output_dir, "output")

  @impl true
  def handle_init(_ctx, socket: socket) do
    source_bin = %SourceBin{
      socket: socket
    }

    sink_bin = %SinkBin{
      manifest_module: Membrane.HTTPAdaptiveStream.HLS,
      target_window_duration: :infinity,
      mode: :live,
      hls_mode: :muxed_av,
      persist?: false,
      storage: %Membrane.HTTPAdaptiveStream.Storages.FileStorage{directory: @stream_output_dir}
      # TODO: Create storage service
      # storage: %Viewbox.FileStorage{
      #   location: @stream_output_dir,
      #   socket: socket
      # }
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
        # %{user: user} = Map.get(sockets, state.socket)
        # Vods.create_vod(%{user: user})
        Map.delete(sockets, state.socket)
      end
    )

    {[], state}
  end

  def get_live_streams() do
    Agent.get(
      StreamCore.SocketAgent,
      fn sockets ->
        Map.values(sockets)
      end
    )
  end

  # def get_live_stream(username: username) do
  #   case get_live_streams()
  #        |> Enum.find(fn live_stream -> live_stream.user.username == username end) do
  #     nil -> %LiveStream{}
  #     x -> x
  #   end
  # end

  def get_live_stream(socket: socket) do
    case Agent.get(StreamCore.SocketAgent, fn sockets -> sockets[socket] end) do
      nil -> %LiveStream{}
      x -> x
    end
  end

  def get_live_stream(_), do: nil

  def update_live_stream(nil, _), do: %LiveStream{}

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

    live_stream = get_live_stream(socket: socket)

    # case live_stream.user do
    #   nil ->
    #     nil

    #   user ->
    #     Phoenix.PubSub.broadcast(
    #       Viewbox.PubSub,
    #       "live:#{user.username}",
    #       live_stream
    #     )
    # end

    live_stream
  end

  # def get_thumbnail(user_id, vod_id) do
  #   dir =
  #     case vod_id do
  #       nil -> @stream_live_dir
  #       vod_id -> Integer.to_string(vod_id)
  #     end
  #   [@stream_output_dir, Integer.to_string(user_id), dir]
  #   |> Path.join()
  #   |> get_thumbnail_base64()
  # end

  # defp get_thumbnail_base64(path) do
  #   from = [path, @stream_output_file] |> Path.join()
  #   to = [path, "thumbnail.png"] |> Path.join()
  #   System.cmd(
  #     "ffmpeg",
  #     [
  #       "-i",
  #       from,
  #       "-vframes",
  #       "1",
  #       "-s",
  #       "1280x720",
  #       "-ss",
  #       "1",
  #       to,
  #       "-y",
  #       "-hide_banner"
  #     ]
  #   )
  #   case File.read(to) do
  #     {:ok, content} -> Base.encode64(content)
  #     {:error, _} -> nil
  #   end
  # end
end
