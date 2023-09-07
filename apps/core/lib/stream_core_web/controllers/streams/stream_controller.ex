defmodule StreamCoreWeb.StreamController do
  alias StreamCoreWeb.Validator

  use StreamCoreWeb, :controller

  @stream_output_dir Application.compile_env(:stream_core, :stream_output_dir, "output")
  @stream_live_dir Application.compile_env(:stream_core, :stream_live_dir, "live")

  @index_stream_params %{
    filename: [type: :string, required: true],
    user_id: [type: :string, required: true]
  }

  def index(conn, params) do
    with {:ok, params} <- Validator.cast(params, @index_stream_params),
         path <- format_path(params) do
      case File.exists?(path) do
        true ->
          send_file(conn, 200, path)

        false ->
          send_resp(conn, 404, "File not found")
      end
    end
  end

  defp format_path(%{user_id: user_id, filename: filename}) do
    [@stream_output_dir, user_id, @stream_live_dir, filename]
    |> Path.join()
    |> Path.expand()
  end
end
