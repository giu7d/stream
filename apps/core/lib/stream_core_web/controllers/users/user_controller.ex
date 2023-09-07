defmodule StreamCoreWeb.UserController do
  use StreamCoreWeb, :controller

  @create_user_session_params %{
    user: %{
      email: [type: :string, required: true],
      username: [type: :string, required: true],
      password: [type: :string, required: true]
    }
  }
  def create(conn, _params) do
    conn
    |> put_status(:ok)
  end
end
