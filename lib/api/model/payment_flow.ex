defmodule Tester.Api.Model.PaymentFlow do
  alias Tester.Api.Model

  defstruct [
    :type
  ]

  @type t() :: %__MODULE__{
          :type => String.t()
        }

  @type variants() ::
          Model.PaymentFlowHold.t()
          | Model.PaymentFlowInstant.t()
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.PaymentFlow do
  alias Tester.Api.Model

  @spec transform(Model.PaymentFlow.t(), map()) :: Model.PaymentFlow.variants()
  def transform(_type, value) do
    struct =
      case Map.get(value, "type") do
        "PaymentFlowHold" -> %Model.PaymentFlowHold{}
        "PaymentFlowInstant" -> %Model.PaymentFlowInstant{}
      end

    Tester.Api.Transformer.transform(struct, value)
  end
end
