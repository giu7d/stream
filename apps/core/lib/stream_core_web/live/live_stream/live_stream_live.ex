defmodule StreamCoreWeb.LiveStreamLive do
  use StreamCoreWeb, :live_view

  @stream_live_file Application.compile_env(:viewbox, :stream_live_file, "live.m3u8")

  def mount(_params, _session, socket) do
    {:ok, assign(socket, stream_live_file: @stream_live_file)}
  end

  def unmount(_reason, _) do
  end
end
