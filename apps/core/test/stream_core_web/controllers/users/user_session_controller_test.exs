defmodule StreamCoreWeb.UserSessionControllerTest do
  use StreamCoreWeb.ConnCase

  import StreamCore.Mocks
  import StreamCore.Factories
  import StreamCore.Helpers

  @auth_cookie_name "_stream_core_auth"

  describe "POST /api/users/login" do
    test "grant user access successfully", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> with_test_session()
        |> post(~p"/api/users/login", %{
          user: %{
            username: user.username,
            password: gen_password()
          }
        })

      assert conn
             |> fetch_cookies()
             |> Map.get(:cookies)
             |> Map.get(@auth_cookie_name)

      assert equals(conn.status, 200)

      assert get_session(conn, :user_token)

      assert match_json(conn.resp_body, %{
               email: user.email,
               username: user.username,
               stream_key: nil
             })
    end
  end

  describe "DELETE /api/users/logout" do
    test "revoke user access successfully", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> with_authenticated_session(user)
        |> delete(~p"/api/users/logout")

      assert conn
             |> fetch_cookies()
             |> Map.get(:cookies)
             |> Map.equal?(%{})

      refute get_session(conn, :user_token)

      assert equals(conn.status, 200)
    end
  end
end
