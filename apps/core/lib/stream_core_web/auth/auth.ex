defmodule StreamCoreWeb.Auth do
  alias StreamCore.Users.UserToken
  alias StreamCore.Users

  use StreamCoreWeb, :verified_routes

  import Plug.Conn

  @max_age 60 * 60 * 24 * 60
  @auth_cookie_name "_stream_core_auth"
  @auth_cookie_options [sign: true, max_age: @max_age, same_site: "Lax"]

  def grant_user_authentication(conn, user, params \\ %{}) do
    with {:ok, %UserToken{} = session_token} <- Users.create_user_session_token(user) do
      {:ok,
       conn
       |> renew_session()
       |> put_session_token(session_token.token)
       |> maybe_write_cookie(session_token.token, params)}
    end
  end

  def revoke_user_authentication(conn) do
    with token <- get_session(conn, :user_token),
         {:ok, _} <- Users.delete_user_session_token(token) do
      # It also sets a `:live_socket_id` key in the session,
      # so LiveView sessions are identified and automatically
      # disconnected on log out
      if live_socket_id = get_session(conn, :live_socket_id) do
        StreamCoreWeb.Endpoint.broadcast(live_socket_id, "disconnect", %{})
      end

      {:ok,
       conn
       |> renew_session()
       |> delete_resp_cookie(@auth_cookie_name)}
    end
  end

  def is_user_authenticated(conn) do
    not is_nil(conn.assigns.current_user)
  end

  defp maybe_write_cookie(conn, token, %{remember_me: true}) do
    put_resp_cookie(conn, @auth_cookie_name, token, @auth_cookie_options)
  end

  defp maybe_write_cookie(conn, _token, _params), do: conn

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end

  defp put_session_token(conn, token) do
    conn
    |> put_session(:user_token, token)
    |> put_session(:live_socket_id, "users_sessions:#{Base.url_encode64(token)}")
  end
end
