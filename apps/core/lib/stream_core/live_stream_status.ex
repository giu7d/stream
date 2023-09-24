defmodule StreamCore.LiveStreamStatus do
  alias StreamCore.LiveStream.Stream
  alias StreamCore.Users.User

  # User specific broadcast status
  def subscribe(%User{} = user) do
    Phoenix.PubSub.subscribe(StreamCore.PubSub, "live:status:#{user.username}")
  end

  def broadcast_stream_change(%Stream{} = stream) do
    Phoenix.PubSub.broadcast(
      StreamCore.PubSub,
      "live:status:#{stream.user.username}",
      {:stream_changed, stream}
    )
  end

  def broadcast_stream_offline(%Stream{} = stream) do
    Phoenix.PubSub.broadcast(
      StreamCore.PubSub,
      "live:status:#{stream.user.username}",
      {:stream_offline, stream}
    )
  end

  # Universal broadcast status
  def subscribe() do
    Phoenix.PubSub.subscribe(StreamCore.PubSub, "live:status")
  end

  def broadcast_universal_stream_offline(%Stream{} = stream) do
    Phoenix.PubSub.broadcast(
      StreamCore.PubSub,
      "live:status",
      {:universal_stream_offline, stream}
    )
  end

  def broadcast_universal_stream_online(%Stream{} = stream) do
    Phoenix.PubSub.broadcast(
      StreamCore.PubSub,
      "live:status",
      {:universal_stream_online, stream}
    )
  end
end
