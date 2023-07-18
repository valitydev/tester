defmodule Tester.Api.Model.PaymentResourceParams do
  alias Tester.Api.Model.ClientInfo
  alias Tester.Api.Model.PaymentTool

  defstruct [
    :externalID,
    :paymentTool,
    :clientInfo
  ]

  @type t() :: %__MODULE__{
          :externalID => String.t() | nil,
          :paymentTool => PaymentTool.variants(),
          :clientInfo => ClientInfo.t()
        }
end

defimpl Poison.Encoder, for: Tester.Api.Model.PaymentResourceParams do
  alias Tester.Api.Model

  @spec encode(Model.PaymentResourceParams.t(), Poison.Encoder.options()) :: iodata()
  def encode(value, options) do
    value
    |> Map.from_struct()
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> Poison.Encoder.encode(options)
  end
end
