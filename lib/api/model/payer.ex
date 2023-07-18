defmodule Tester.Api.Model.Payer do
  alias Tester.Api.Model

  defstruct [
    :payerType
  ]

  @type t() :: %__MODULE__{
          :payerType => String.t()
        }

  @type variants() :: Model.PaymentResourcePayer.t()
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.Payer do
  alias Tester.Api.Model

  @spec transform(Model.Payer.t(), map()) :: Model.Payer.variants()
  def transform(_type, value) do
    struct =
      case Map.get(value, "payerType") do
        "PaymentResourcePayer" -> %Model.PaymentResourcePayer{}
      end

    Tester.Api.Transformer.transform(struct, value)
  end
end
