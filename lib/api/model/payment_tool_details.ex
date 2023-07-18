defmodule Tester.Api.Model.PaymentToolDetails do
  alias Tester.Api.Model

  defstruct [
    :detailsType
  ]

  @type t() :: %__MODULE__{
          :detailsType => String.t()
        }

  @type variants() :: Model.PaymentToolDetailsBankCard.t()
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.PaymentToolDetails do
  alias Tester.Api.Model

  @spec transform(Model.PaymentToolDetails.t(), map()) :: Model.PaymentToolDetails.variants()
  def transform(_type, value) do
    struct =
      case Map.get(value, "detailsType") do
        "PaymentToolDetailsBankCard" -> %Model.PaymentToolDetailsBankCard{}
      end

    Tester.Api.Transformer.transform(struct, value)
  end
end
