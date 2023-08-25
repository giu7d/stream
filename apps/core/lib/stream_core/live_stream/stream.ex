defmodule StreamCore.LiveStream.Stream do
  alias StreamCore.Users.User

  @required_keys []
  @optional_keys [:user, :socket]
  @default_keys [is_live?: false, viewer_count: 0]

  defstruct @required_keys ++ @optional_keys ++ @default_keys

  @type t :: %__MODULE__{
          viewer_count: non_neg_integer(),
          socket: port(),
          user: User.t(),
          is_live?: boolean()
        }
end
