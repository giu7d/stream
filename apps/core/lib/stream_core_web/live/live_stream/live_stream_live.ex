defmodule StreamCoreWeb.LiveStreamLive do
  alias StreamCore.LiveStream
  alias StreamCore.LiveStream.Stream
  alias StreamCore.LiveStreamMonitor
  alias StreamCore.LiveStreamStatus
  alias StreamCore.Users
  alias StreamCore.Users.User
  alias StreamCoreWeb.Validator

  use StreamCoreWeb, :live_view

  @stream_output_file Application.compile_env(:stream_core, :stream_output_file, "live.m3u8")

  @live_stream_params %{
    username: [type: :string]
  }
  def mount(params, _session, socket) do
    with {:ok, params} <- Validator.cast(params, @live_stream_params),
         {:ok, %User{} = user} <- Users.find_user(%{username: params.username}),
         # refactor this
         %Stream{} = live_stream <-
           LiveStream.find_live_stream(username: params.username)
           |> then(
             &LiveStream.update_live_stream(&1.socket, fn stream ->
               %{stream | viewer_count: stream.viewer_count + 1}
             end)
           ) do
      LiveStreamStatus.subscribe(user)
      LiveStreamMonitor.monitor(__MODULE__, params)

      {:ok,
       assign(
         socket,
         page_title: user.username,
         stream: live_stream,
         user: user,
         stream_output_file: @stream_output_file,
         stream_is_live?: live_stream.is_live?,
         stream_views: live_stream.viewer_count,
         stream_user: %{
           name: user.username,
           avatar_url: "https://avatars.githubusercontent.com/u/30274817?v=4"
         }
       )}
    end
  end

  def unmount(_reason, params) do
    with {:ok, params} <- Validator.cast(params, @live_stream_params) do
      # refactor this
      LiveStream.find_live_stream(username: params.username)
      |> then(
        &LiveStream.update_live_stream(&1.socket, fn stream ->
          %{stream | viewer_count: max(0, stream.viewer_count - 1)}
        end)
      )
    end
  end

  def handle_info({:stream_changed, stream}, socket) do
    {:noreply,
     assign(socket,
       stream: stream,
       stream_views: stream.viewer_count,
       stream_is_live?: stream.is_live?
     )}
  end

  def handle_info({:stream_offline, stream}, socket) do
    {:noreply,
     assign(socket,
       stream: stream,
       stream_views: 0,
       stream_is_live?: false
     )}
  end
end
