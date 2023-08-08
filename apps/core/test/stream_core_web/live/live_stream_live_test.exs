defmodule StreamCoreWeb.LiveStreamLiveTest do
  use StreamCoreWeb.ConnCase

  describe "GET /" do
    test "mount view", %{conn: conn} do
      assert {:ok, view, _html} = live(conn, ~p"/")

      assert view
             |> element("video#player")
             |> has_element?()
    end
  end
end
