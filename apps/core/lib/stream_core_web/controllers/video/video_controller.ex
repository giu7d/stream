defmodule StreamCoreWeb.VideoController do
  use StreamCoreWeb, :controller

  @output_dir Application.compile_env(:stream_core, :stream_output_dir, "output")

  def index(conn, %{"id" => id}) do
    path = [@output_dir, id] |> Path.join() |> Path.expand()

    if File.exists?(path) do
      conn |> Plug.Conn.send_file(200, path)
    else
      conn |> Plug.Conn.send_resp(404, "File not found")
    end
  end
end
