defmodule StreamCoreWeb.UserSessionController do
  alias StreamCore.Users.User
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
    handle_create(conn, params, :api)
  end

  def create_live(conn, params) do
    handle_create(conn, params, :live_view)
  end

  defp handle_create(conn, params, opts) do
    with {:ok, params} <- Validator.cast(params, @create_user_session_params),
         %User{} = user <-
           Users.find_user_with_password(params.user.username, params.user.password) do
      conn
      |> Auth.grant_user_authentication(user, %{remember_me: true})
      |> handle_response_view(user, opts)
    else
      _ ->
        conn
        |> put_flash(:error, "Invalid email or password")
        |> redirect(to: ~p"/login")
    end
  end

  defp handle_response_view(conn, _user, :live_view), do: redirect(conn, to: ~p"/")

  defp handle_response_view(conn, user, :api),
    do: conn |> put_status(:ok) |> render("user_session_create.json", user: user)

  def delete(conn, _params) do
    conn
    |> Auth.revoke_user_authentication()
    |> send_resp(:ok, "User access removed!")
  end
end
