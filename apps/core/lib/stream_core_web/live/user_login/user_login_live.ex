defmodule StreamCoreWeb.UserLoginLive do
  alias StreamCore.Users.User
  alias StreamCoreWeb.Validator

  use StreamCoreWeb, :live_view

  @form_params %{
    user: %{
      username: [type: :string],
      password: [type: :string]
    }
  }

  def mount(_params, _session, socket) do
    username = live_flash(socket.assigns.flash, :username)
    form = to_form(%{"username" => username}, as: "user")

    {
      :ok,
      assign(
        socket,
        page_title: "Log In",
        form: form
      ),
      temporary_assigns: [form: form]
    }
  end

  def handle_event("validate", params, socket) do
    with {:ok, params} <- Validator.cast(params, @form_params) do
      form =
        %User{}
        |> User.login_changeset(params.user)
        |> Map.put(:action, :validate)
        |> to_form()

      {:noreply, assign(socket, form: form)}
    end
  end
end
