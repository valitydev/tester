defmodule Tester.Api.Model.PaymentFlowInstant do
  @derive [Tester.Api.Transformer]
  defstruct type: "PaymentFlowInstant"

  @type t() :: %__MODULE__{
          :type => String.t()
        }
end
