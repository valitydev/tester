defmodule Tester.Api.Model.PaymentFlowHold do
  @derive [Tester.Api.Transformer]
  defstruct [
    :onHoldExpiration,
    :heldUntil,
    type: "PaymentFlowHold"
  ]

  @type t() :: %__MODULE__{
          :type => String.t(),
          :onHoldExpiration => String.t(),
          :heldUntil => DateTime.t() | nil
        }
end
