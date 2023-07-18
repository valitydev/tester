defmodule Tester.Api.Model.PaymentTool do
  alias Tester.Api.Model

  defstruct [
    :paymentToolType
  ]

  @type t() :: %__MODULE__{
          :paymentToolType => String.t()
        }

  @type variants() :: Model.CardData.t()
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.PaymentTool do
  alias Tester.Api.Model

  @spec transform(Model.PaymentTool.t(), map()) :: Model.PaymentTool.variants()
  def transform(_type, value) do
    struct =
      case Map.get(value, "paymentToolType") do
        "CardData" -> %Model.CardData{}
      end

    Tester.Api.Transformer.transform(struct, value)
  end
end
