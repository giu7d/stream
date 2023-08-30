defmodule StreamCoreWeb.UserSessionJson do
  alias StreamCore.Users.User

  def render("user_session_create.json", %{user: %User{} = user}) do
    %{
      email: user.email,
      username: user.username,
      stream_key: user.stream_key
    }
  end
end
