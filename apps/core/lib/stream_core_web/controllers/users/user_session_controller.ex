defmodule StreamCoreWeb.UserSessionController do
  alias StreamCore.Users.User
  alias StreamCore.Users
  alias StreamCoreWeb.Validator

  use StreamCoreWeb, :controller

  @create_user_session_params %{
    user: %{
      username: [type: :string],
      password: [type: :string]
    }
  }
  def create(conn, params) do
    with {:ok, params} <- Validator.cast(params, @create_user_session_params),
         %User{} = user <-
           Users.find_user_with_password(params.user.username, params.user.password) do
      conn
      # |> put_flash(:info, info)
      # |> UserAuth.log_in_user(user, user_params)
      |> redirect(to: ~p"/test")
    else
      _ ->
        conn
        # |> put_flash(:error, "Invalid email or password")
        |> redirect(to: ~p"/login")
    end
  end
end
