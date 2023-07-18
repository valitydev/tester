defmodule Tester.Api.Model.Shop do
  @derive [Tester.Api.Transformer]
  defstruct [
    :id,
    :createdAt,
    :isBlocked,
    :isSuspended,
    :categoryID,
    :contractID,
    :payoutToolID,
    :scheduleID
  ]

  @type t() :: %__MODULE__{
          :id => String.t(),
          :createdAt => DateTime.t(),
          :isBlocked => boolean(),
          :isSuspended => boolean(),
          :categoryID => integer(),
          :contractID => String.t(),
          :payoutToolID => String.t() | nil,
          :scheduleID => integer() | nil
        }
end
