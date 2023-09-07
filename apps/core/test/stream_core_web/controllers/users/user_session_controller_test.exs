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

    test "deny user access if wrong username", %{conn: conn} do
      conn =
        conn
        |> with_test_session()
        |> post(~p"/api/users/login", %{
          user: %{
            username: "wrong_username",
            password: gen_password()
          }
        })

      assert equals(conn.status, 401)

      refute get_session(conn, :user_token)
    end

    test "deny user access if wrong password", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> with_test_session()
        |> post(~p"/api/users/login", %{
          user: %{
            username: user.username,
            password: "wrong_password"
          }
        })

      assert equals(conn.status, 401)

      refute get_session(conn, :user_token)
    end

    test "deny user access if wrong request format", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> with_test_session()
        |> post(~p"/api/users/login", %{
          user: %{
            username: user.username
          }
        })

      assert equals(conn.status, 400)

      refute get_session(conn, :user_token)
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

    test "can not revoke user if no authenticated session", %{conn: conn} do
      conn =
        conn
        |> with_test_session()
        |> delete(~p"/api/users/logout")

      refute get_session(conn, :user_token)

      assert equals(conn.status, 400)
    end
  end
end
