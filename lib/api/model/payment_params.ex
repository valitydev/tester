defmodule Tester.Api.Model.PaymentParams do
  alias Tester.Api.Model.PaymentFlow
  alias Tester.Api.Model.Payer

  defstruct [
    :externalID,
    :flow,
    :payer,
    :processingDeadline,
    :makeRecurrent,
    :metadata
  ]

  @type t() :: %__MODULE__{
          :externalID => String.t() | nil,
          :flow => PaymentFlow.variants(),
          :payer => Payer.variants(),
          :processingDeadline => String.t() | nil,
          :makeRecurrent => boolean() | nil,
          :metadata => map() | nil
        }
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.PaymentParams do
  alias Tester.Api.Model
  alias Tester.Api.Transform

  @spec transform(Model.PaymentParams.t(), map()) :: Model.PaymentParams.t()
  def transform(type, value) do
    Transform.transform_with_fields(type, value,
      flow: %Model.PaymentFlow{},
      payer: %Model.Payer{}
    )
  end
end

defimpl Poison.Encoder, for: Tester.Api.Model.PaymentParams do
  alias Tester.Api.Model

  @spec encode(Model.PaymentParams.t(), Poison.Encoder.options()) :: iodata()
  def encode(value, options) do
    value
    |> Map.from_struct()
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> Poison.Encoder.encode(options)
  end
end
