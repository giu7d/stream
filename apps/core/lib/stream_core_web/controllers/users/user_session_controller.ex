defmodule StreamCoreWeb.UserSessionController do
  alias StreamCore.Users
  alias StreamCoreWeb.Auth
  alias StreamCoreWeb.Validator

  use StreamCoreWeb, :controller

  action_fallback(StreamCoreWeb.FallbackController)

  plug(:put_view, json: StreamCoreWeb.UserSessionJson)

  @create_user_session_params %{
    user: %{
      username: [type: :string, required: true],
      password: [type: :string, required: true]
    }
  }

  def create(conn, params) do
    with {:ok, params} <-
           Validator.cast(params, @create_user_session_params),
         {:ok, user} <-
           Users.find_user_with_password(params.user.username, params.user.password),
         {:ok, conn} <-
           Auth.grant_user_authentication(conn, user, %{remember_me: true}) do
      handle_session_create_response(conn, user)
    end
  end

  def delete(conn, _params) do
    with {:ok, conn} <- Auth.revoke_user_authentication(conn) do
      handle_session_deleted_response(conn)
    end
  end

  defp handle_session_create_response(conn, user) do
    if Validator.is_api_scope?(conn) do
      conn
      |> put_status(:ok)
      |> render("user_session_create.json", user: user)
    else
      redirect(conn, to: ~p"/")
    end
  end

  defp handle_session_deleted_response(conn) do
    if Validator.is_api_scope?(conn) do
      conn
      |> send_resp(:ok, "user session removed")
    else
      redirect(conn, to: ~p"/")
    end
  end
end
