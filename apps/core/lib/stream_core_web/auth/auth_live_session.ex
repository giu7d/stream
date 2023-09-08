defmodule StreamCoreWeb.Auth.AuthLiveSession do
  alias StreamCoreWeb.Auth
  alias StreamCore.Users

  use StreamCoreWeb, :verified_routes

  import Phoenix.Component

  @auth_cookie_name "_stream_core_auth"

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated_user, _params, session, socket) do
    socket
    |> mount_current_user(session)
    |> Auth.is_user_authenticated()
    |> case do
      true -> {:cont, socket}
      _ -> handle_error(socket)
    end
  end

  def on_mount(:redirect_authenticated_user, _params, session, socket) do
    socket
    |> mount_current_user(session)
    |> Auth.is_user_authenticated()
    |> case do
      true -> {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
      _ -> {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      with user_token <- session["user_token"],
           {:ok, user} <- Users.find_user_by_session_token(user_token) do
        user
      else
        _ -> nil
      end
    end)
  end

  defp handle_error(socket) do
    {:halt,
     socket
     |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
     |> Phoenix.LiveView.redirect(to: ~p"/login")}
  end
end
