defmodule StreamCoreWeb.LiveStreamLive do
  alias StreamCore.Users.User
  alias StreamCore.Users
  alias StreamCore.LiveStream.Stream
  alias StreamCore.LiveStream
  alias StreamCoreWeb.Validator

  use StreamCoreWeb, :live_view

  @stream_output_file Application.compile_env(:stream_core, :stream_output_file, "live.m3u8")

  @live_stream_params %{
    username: [type: :string]
  }
  def mount(params, _session, socket) do
    with {:ok, params} <- Validator.cast(params, @live_stream_params),
         {:ok, %User{} = user} <- Users.find_user(%{username: params.username}),
         %Stream{} = live_stream <- LiveStream.find_live_stream(username: params.username) do
      Phoenix.PubSub.subscribe(StreamCore.PubSub, "live:#{params.username}")

      {:ok,
       assign(
         socket,
         page_title: user.username,
         stream: live_stream,
         user: user,
         stream_output_file: @stream_output_file,
         stream_is_live?: true,
         stream_views: 1000,
         stream_user: %{
           name: user.username,
           avatar_url: "https://avatars.githubusercontent.com/u/30274817?v=4"
         }
       )}
    end
  end

  def unmount(_reason, _params) do
    # with {:ok, params} <- Validator.cast(params, @live_stream_params),
    #      live_stream <- LiveStream.find_live_stream(username: params.username) do
    #   {:ok, live_stream}
    # end
  end
end
