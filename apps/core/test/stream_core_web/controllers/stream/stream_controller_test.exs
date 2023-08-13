defmodule StreamCoreWeb.StreamControllerTest do
  use StreamCoreWeb.ConnCase

  describe "GET /api/stream/:filename" do
    test "returns File if file found", %{conn: conn} do
      response = get(conn, ~p"/api/stream/test.m3u8")

      assert response.resp_body == "This is a test file content\n"
      assert response.status == 200
    end

    test "returns 404 if file not found", %{conn: conn} do
      response = get(conn, ~p"/api/stream/not_found.m3u8")

      assert response.resp_body == "File not found"
      assert response.status == 404
    end
  end
end