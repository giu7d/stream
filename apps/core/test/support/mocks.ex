defmodule StreamCore.Mocks do
  def gen_username, do: "ab#{System.unique_integer()}" |> String.slice(0..19)

  def gen_email, do: "user#{System.unique_integer()}@example.com"

  def gen_password, do: "valid_password"

  def gen_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      username: gen_username(),
      email: gen_email(),
      password: gen_password()
    })
  end

  def gen_token, do: :crypto.strong_rand_bytes(32)
end
