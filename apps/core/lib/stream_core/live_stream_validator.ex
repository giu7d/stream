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
    message.stream_key
    |> format_stream_key()
    |> Users.find_user()
    |> validate_stream_status()
    |> start_stream(impl)
  end

  @impl true
  def validate_set_data_frame(_impl, _message) do
    {:ok, :data_frame_started}
  end

  defp start_stream({:ok, %User{} = user}, impl) do
    LiveStream.update_live_stream(
      impl.socket,
      fn _ -> %{is_live?: true, user: user} end
    )

    Phoenix.PubSub.broadcast(
      StreamCore.PubSub,
      "streamer_live",
      {:streamer_went_live, user}
    )

    {:ok, :stream_started}
  end

  defp start_stream({:error, reason}, _), do: {:error, reason}

  defp format_stream_key(message_stream_key) do
    [username, _stream_key] = String.split(message_stream_key, "_")

    %{username: username}
  end

  defp validate_stream_status({:ok, %User{} = user}) do
    LiveStream.list_live_streams()
    |> Enum.filter(fn stream -> stream.user.username == user.username end)
    |> Enum.empty?()
    |> case do
      true -> {:ok, user}
      false -> {:error, :stream_duplicated}
    end
  end

  defp validate_stream_status({:error, reason}), do: {:error, reason}
end
