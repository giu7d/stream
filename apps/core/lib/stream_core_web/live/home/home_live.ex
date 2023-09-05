defmodule StreamCoreWeb.HomeLive do
  use StreamCoreWeb, :live_view

  def mount(_params, _session, socket) do
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

  defp get_live_streams() do
    StreamCore.SocketAgent
    |> Agent.get(& &1)
    |> Map.values()
  end
end
