defmodule StreamCoreWeb.LiveController do
  use StreamCoreWeb, :controller

  def index(conn, %{"id" => id}) do
    path = "output/#{id}"

    if File.exists?(path) do
      conn |> Plug.Conn.send_file(200, path)
    else
      conn |> Plug.Conn.send_resp(404, "File not found")
    end
  end
end
