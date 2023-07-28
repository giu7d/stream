defmodule StreamCoreWeb.VideoController do
  use StreamCoreWeb, :controller

  @stream_output_dir Application.compile_env(:stream_core, :stream_output_dir, "output")
  @stream_live_dir Application.compile_env(:stream_core, :stream_live_dir, "live")

  def index(conn, %{"id" => id}) do
    path =
      [@stream_output_dir, @stream_live_dir, id]
      |> Path.join()
      |> Path.expand()

    if File.exists?(path) do
      Plug.Conn.send_file(conn, 200, path)
    else
      Plug.Conn.send_resp(conn, 404, "File not found")
    end
  end
end
