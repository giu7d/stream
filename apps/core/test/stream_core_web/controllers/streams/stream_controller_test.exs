defmodule StreamCoreWeb.StreamControllerTest do
  use StreamCoreWeb.ConnCase

  import StreamCore.Helpers

  describe "GET /api/streams/:user_id/:filename" do
    test "returns file if file found", %{conn: conn} do
      conn = get(conn, ~p"/api/streams/9999/test.m3u8")
      assert equals(conn.resp_body, "This is a test file content\n")
      assert equals(conn.status, 200)
    end

    test "returns 404 if file not found", %{conn: conn} do
      conn = get(conn, ~p"/api/streams/9999/not_found.m3u8")
      assert equals(conn.resp_body, "File not found")
      assert equals(conn.status, 404)
    end
  end
end
