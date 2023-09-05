defmodule StreamCoreWeb.UserController do
  use StreamCoreWeb, :controller

  @create_user_session_params %{
    user: %{
      email: [type: :string],
      username: [type: :string],
      password: [type: :string]
    }
  }
  def create(conn, _params) do
    conn
    |> put_status(:ok)
  end
end
