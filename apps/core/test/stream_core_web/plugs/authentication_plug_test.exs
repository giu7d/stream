defmodule StreamCoreWeb.AuthenticationPlugTest do
  alias StreamCoreWeb.AuthenticationPlug

  use StreamCoreWeb.ConnCase

  import StreamCore.Factories
  import StreamCore.Helpers
  import StreamCore.Mocks

  describe "call/2" do
    test "authenticate connection successfully", %{conn: conn} do
      user = insert(:user)

      assert conn =
               conn
               |> with_authenticated_session(user)
               |> AuthenticationPlug.call(nil)

      assert is_nil(conn.status)
    end

    test "rejects authenticating if invalid token ", %{conn: conn} do
      invalid_token = gen_token()

      assert conn =
               conn
               |> with_test_session()
               |> configure_session(renew: true)
               |> clear_session()
               |> put_session(:user_token, invalid_token)
               |> AuthenticationPlug.call(%{})

      assert equals(conn.status, 403)
    end

    test "rejects authenticating if no token ", %{conn: conn} do
      assert conn =
               conn
               |> with_test_session()
               |> AuthenticationPlug.call(%{})

      assert equals(conn.status, 403)
    end
  end
end
