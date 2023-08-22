defmodule StreamCore.Factories do
  alias StreamCore.Users.User
  alias StreamCore.Mocks

  use ExMachina.Ecto, repo: StreamCore.Repo

  def user_factory do
    email = Mocks.gen_email()
    username = Mocks.gen_username()
    password = Mocks.gen_password()

    %User{
      email: email,
      username: username,
      password: password,
      hashed_password: Bcrypt.hash_pwd_salt(password)
    }
  end
end
