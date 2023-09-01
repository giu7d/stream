defmodule StreamCoreWeb.UserSessionController do
  alias StreamCore.Users
  alias StreamCoreWeb.Auth
  alias StreamCoreWeb.Validator

  use StreamCoreWeb, :controller

  plug(:put_view, json: StreamCoreWeb.UserSessionJson)

  @create_user_session_params %{
    user: %{
      username: [type: :string],
      password: [type: :string]
    }
  }
  def create(conn, params) do
    with {:ok, params} <- Validator.cast(params, @create_user_session_params),
         user <- Users.find_user_with_password(params.user.username, params.user.password) do
      conn
      |> Auth.grant_user_authentication(user, %{remember_me: true})
      |> put_status(:ok)
      |> render("user_session_create.json", user: user)
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.revoke_user_authentication()
    |> send_resp(:ok, "User access removed!")
  end
end
