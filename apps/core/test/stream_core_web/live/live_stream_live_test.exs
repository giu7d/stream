defmodule StreamCoreWeb.LiveStreamLiveTest do
  use StreamCoreWeb.ConnCase

  import StreamCore.Factories

  describe "GET /:username" do
    test "mount view", %{conn: conn} do
      user = insert(:user)

      assert {:ok, view, _html} = live(conn, ~p"/#{user.username}")

      assert view
             |> element("video#player")
             |> has_element?()
    end
  end
end
