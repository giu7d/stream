defmodule StreamCoreWeb.LiveStreamLive do
  use StreamCoreWeb, :live_view

  @stream_live_file Application.compile_env(:stream_core, :stream_live_file, "live.m3u8")

  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       stream_live_file: @stream_live_file,
       stream_is_live?: true,
       stream_views: 1000,
       stream_user: %{
         name: "Giuseppe Setem",
         avatar_url: "https://avatars.githubusercontent.com/u/30274817?v=4"
       }
     )}
  end

  def unmount(_reason, _) do
  end
end
