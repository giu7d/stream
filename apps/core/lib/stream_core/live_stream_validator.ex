defimpl Membrane.RTMP.MessageValidator, for: StreamCore.LiveStream.StreamValidator do
  alias StreamCore.LiveStream
  alias StreamCore.Users.User
  alias StreamCore.Users

  @impl true
  def validate_release_stream(_impl, _message) do
    {:ok, :stream_released}
  end

  @impl true
  def validate_publish(impl, message) do
    validate_message_stream_key(impl, message.stream_key)
  end

  @impl true
  def validate_set_data_frame(_impl, _message) do
    {:ok, :data_frame_started}
  end

  defp validate_message_stream_key(impl, message_stream_key) do
    message_stream_key
    |> handle_message_stream_key()
    |> Map.take([:username])
    |> Users.find_user()
    |> case do
      {:ok, %User{} = user} ->
        handle_user_stream_key(impl, user)

      {:error, motive} ->
        {:error, motive}
    end
  end

  defp handle_user_stream_key(impl, %User{} = user) do
    LiveStream.update_live_stream(
      impl.socket,
      fn _ -> %{is_live?: true, user: user} end
    )

    Phoenix.PubSub.broadcast(
      StreamCore.PubSub,
      "streamer_live",
      {:streamer_went_live, user}
    )

    {:ok, :stream_published}
  end

  defp handle_message_stream_key(message_stream_key) do
    [username, stream_key] = String.split(message_stream_key, "_")

    %{username: username, stream_key: stream_key}
  end
end
