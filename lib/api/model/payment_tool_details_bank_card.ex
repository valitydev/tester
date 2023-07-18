defmodule Tester.Api.Model.PaymentToolDetailsBankCard do
  @derive [Tester.Api.Transformer]
  defstruct [
    :cardNumberMask,
    :first6,
    :last4,
    :paymentSystem,
    :tokenProvider,
    :tokenizationMethod,
    detailsType: "PaymentToolDetailsBankCard"
  ]

  @type t() :: %__MODULE__{
          :detailsType => String.t(),
          :cardNumberMask => String.t(),
          :first6 => String.t() | nil,
          :last4 => String.t() | nil,
          :paymentSystem => String.t(),
          :tokenProvider => String.t() | nil,
          :tokenizationMethod => String.t() | nil
        }
end
