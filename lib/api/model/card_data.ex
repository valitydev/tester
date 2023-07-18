defmodule Tester.Api.Model.CardData do
  @derive [Tester.Api.Transformer]
  defstruct [
    :cardNumber,
    :expDate,
    :cvv,
    :cardHolder,
    paymentToolType: "CardData"
  ]

  @type t() :: %__MODULE__{
          :paymentToolType => String.t(),
          :cardNumber => String.t(),
          :expDate => String.t(),
          :cvv => String.t() | nil,
          :cardHolder => String.t() | nil
        }
end
