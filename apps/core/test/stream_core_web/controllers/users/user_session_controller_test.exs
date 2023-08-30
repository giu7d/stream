defmodule StreamCoreWeb.UserSessionControllerTest do
  use StreamCoreWeb.ConnCase

  import StreamCore.Mocks
  import StreamCore.Factories
  import StreamCore.Helpers

  describe "POST /api/users/login" do
    test "returns logged user", %{conn: conn} do
      user = insert(:user)

      response =
        post(conn, ~p"/api/users/login", %{
          user: %{
            username: user.username,
            password: gen_password()
          }
        })

      assert equals(response.status, 200)

      assert match_json(response.resp_body, %{
               email: user.email,
               username: user.username,
               stream_key: nil
             })
    end
  end
end
