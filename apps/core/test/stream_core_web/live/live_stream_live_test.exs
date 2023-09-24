defmodule StreamCoreWeb.LiveStreamLiveTest do
  use StreamCoreWeb.ConnCase

  import StreamCore.Factories

  describe "GET /:username" do
    test "mount offline view if streamer offline", %{conn: conn} do
      user = insert(:user)

      assert {:ok, view, _html} = live(conn, ~p"/#{user.username}")

      assert view
             |> element("#stream-offline")
             |> has_element?()
    end
  end
end
