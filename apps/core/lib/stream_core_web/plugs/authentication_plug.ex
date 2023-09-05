defmodule StreamCoreWeb.AuthenticationPlug do
  alias StreamCore.Users.User
  alias StreamCore.Users

  import Plug.Conn

  def init(options), do: options

  def call(conn, _options) do
    with {:ok, token} <- handle_get_session(conn, :user_token),
         {:ok, %User{}} <- Users.find_user_by_session_token(token) do
      conn
    else
      _ -> render_error(conn)
    end
  end

  defp handle_get_session(conn, session_key) do
    conn
    |> get_session(session_key)
    |> case do
      nil -> {:error, nil}
      token -> {:ok, token}
    end
  end

  defp render_error(conn) do
    error = Jason.encode!(%{message: "No authentication provided!"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:forbidden, error)
    |> halt()
  end
end
