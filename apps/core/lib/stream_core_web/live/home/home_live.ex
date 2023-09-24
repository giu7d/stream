defmodule StreamCoreWeb.HomeLive do
  alias StreamCore.LiveStream.Stream
  alias StreamCore.LiveStreamStatus
  alias StreamCore.Users

  use StreamCoreWeb, :live_view

  def mount(_params, _session, socket) do
    LiveStreamStatus.subscribe()

    {
      :ok,
      assign(
        socket,
        page_title: "Welcome",
        live_streams: get_live_streams(),
        current_user: socket.assigns.current_user
      )
    }
  end

  def handle_info({:universal_stream_online, stream}, socket),
    do: handle_steam_status_change(stream, socket)

  def handle_info({:universal_stream_offline, stream}, socket),
    do: handle_steam_status_change(stream, socket)

  defp handle_steam_status_change(_, socket) when is_nil(socket.assigns.current_user),
    do: {:noreply, socket}

  defp handle_steam_status_change(%Stream{} = stream, socket) do
    %{
      follower_id: socket.assigns.current_user.id,
      streamer_id: stream.user.id
    }
    |> Users.is_user_following?()
    |> case do
      true ->
        {:noreply,
         assign(
           socket,
           live_streams: get_live_streams()
         )}

      _ ->
        {:noreply, socket}
    end
  end

  defp get_live_streams() do
    StreamCore.LiveStream.list_live_streams()
  end
end
