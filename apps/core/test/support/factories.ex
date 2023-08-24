defmodule StreamCore.Factories do
  alias StreamCore.Users.UserToken
  alias StreamCore.Users.Follower
  alias StreamCore.Users.User

  use ExMachina.Ecto, repo: StreamCore.Repo

  import StreamCore.Mocks

  def user_factory do
    email = gen_email()
    username = gen_username()
    password = gen_password()

    %User{
      email: email,
      username: username,
      password: password,
      hashed_password: Bcrypt.hash_pwd_salt(password)
    }
  end

  def follower_factory do
    user_follower = build(:user)
    user_streamer = build(:user)

    %Follower{
      follower: user_follower,
      streamer: user_streamer
    }
  end

  def user_token_factory do
    user = build(:user)
    token = gen_token()

    %UserToken{
      user: user,
      context: "session",
      token: token
    }
  end
end
