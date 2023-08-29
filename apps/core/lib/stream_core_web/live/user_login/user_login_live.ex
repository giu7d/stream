defmodule StreamCoreWeb.UserLoginLive do
  use StreamCoreWeb, :live_view

  def mount(_params, _session, socket) do
    username = live_flash(socket.assigns.flash, :username)
    form = to_form(%{"username" => username}, as: "user")

    {
      :ok,
      assign(
        socket,
        page_title: "Welcome",
        form: form
      ),
      temporary_assigns: [form: form]
    }
  end
end
