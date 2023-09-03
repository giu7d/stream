defmodule StreamCoreWeb.HomeLive do
  use StreamCoreWeb, :live_view

  def mount(_params, _session, socket) do
    {
      :ok,
      assign(
        socket,
        page_title: "Welcome"
      )
    }
  end
end
