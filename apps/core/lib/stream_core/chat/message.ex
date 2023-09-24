defmodule StreamCore.Chat.Message do
  alias StreamCore.Users.User

  @required_keys [:sender, :content]
  @optional_keys []
  @default_keys [timestamp: DateTime.utc_now()]

  defstruct @required_keys ++ @optional_keys ++ @default_keys

  @type t :: %__MODULE__{
          sender: User.t(),
          content: String.t(),
          timestamp: DateTime.t()
        }
end
