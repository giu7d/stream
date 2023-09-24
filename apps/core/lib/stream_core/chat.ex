defmodule StreamCore.Chat do
  alias StreamCore.Users.User
  alias StreamCore.Chat.Message

  def subscribe(%User{} = streamer) do
    Phoenix.PubSub.subscribe(StreamCore.PubSub, "live:chat:#{streamer.username}")
  end

  def broadcast_message(%User{} = streamer, %User{} = sender, content) do
    message = %Message{
      sender: sender,
      content: content,
      timestamp: DateTime.utc_now()
    }

    Phoenix.PubSub.broadcast(
      StreamCore.PubSub,
      "live:chat:#{streamer.username}",
      {:new_message, message}
    )
  end
end
