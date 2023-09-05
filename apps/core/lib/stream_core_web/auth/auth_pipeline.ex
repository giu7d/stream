defmodule StreamCoreWeb.Auth.AuthPipeline do
  alias StreamCoreWeb.Auth
  alias StreamCore.Users
  alias StreamCore.Users.User

  use StreamCoreWeb, :verified_routes

  import Plug.Conn
  import Phoenix.Controller

  @auth_cookie_name "_stream_core_auth"

  def on_mount(:mount_current_user, _params, session, socket) do
    {:cont, mount_current_user(socket, session)}
  end

  def on_mount(:ensure_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You must log in to access this page.")
        |> Phoenix.LiveView.redirect(to: ~p"/login")

      {:halt, socket}
    end
  end

  def on_mount(:redirect_if_user_is_authenticated, _params, session, socket) do
    socket = mount_current_user(socket, session)

    if socket.assigns.current_user do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, socket}
    end
  end

  defp mount_current_user(socket, session) do
    Phoenix.Component.assign_new(socket, :current_user, fn ->
      if user_token = session["user_token"] do
        {:ok, user} = Users.find_user_by_session_token(user_token)
        user
      end
    end)
  end

  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: ~p"/")
      |> halt()
    else
      conn
    end
  end

  def fetch_current_user(conn, _opts) do
    with {user_token, conn} <- ensure_user_token(conn),
         {:ok, %User{} = user} <- Users.find_user_by_session_token(user_token) do
      assign(conn, :current_user, user)
    else
      _ -> assign(conn, :current_user, nil)
    end
  end

  defp ensure_user_token(conn) do
    if token = get_session(conn, :user_token) do
      {token, conn}
    else
      conn = fetch_cookies(conn, signed: [@auth_cookie_name])

      if token = conn.cookies[@auth_cookie_name] do
        {token, Auth.put_session_token(conn, token)}
      else
        {nil, conn}
      end
    end
  end
end
