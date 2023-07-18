defmodule Tester.Api.Model.Party do
  @derive [Tester.Api.Transformer]
  defstruct [
    :id,
    :isBlocked,
    :isSuspended
  ]

  @type t() :: %__MODULE__{
          :id => String.t(),
          :isBlocked => boolean(),
          :isSuspended => boolean()
        }
end
