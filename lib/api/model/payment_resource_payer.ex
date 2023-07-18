defmodule Tester.Api.Model.PaymentResourcePayer do
  alias Tester.Api.Model.PaymentToolDetails
  alias Tester.Api.Model.ClientInfo
  alias Tester.Api.Model.ContactInfo

  defstruct [
    :paymentToolToken,
    :paymentSession,
    :paymentToolDetails,
    :clientInfo,
    :contactInfo,
    payerType: "PaymentResourcePayer"
  ]

  @type t() :: %__MODULE__{
          :paymentToolToken => String.t(),
          :paymentSession => String.t(),
          :paymentToolDetails => PaymentToolDetails.variants() | nil,
          :clientInfo => ClientInfo.t() | nil,
          :payerType => String.t(),
          :contactInfo => ContactInfo.t()
        }
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.PaymentResourcePayer do
  alias Tester.Api.Model
  alias Tester.Api.Transform

  @spec transform(Model.PaymentResourcePayer.t(), map()) :: Model.PaymentResourcePayer.t()
  def transform(type, value) do
    Transform.transform_with_fields(type, value,
      paymentToolDetails: %Model.PaymentToolDetails{},
      clientInfo: %Model.ClientInfo{},
      contactInfo: %Model.ContactInfo{}
    )
  end
end

defimpl Poison.Encoder, for: Tester.Api.Model.PaymentResourcePayer do
  alias Tester.Api.Model

  @spec encode(Model.PaymentResourcePayer.t(), Poison.Encoder.options()) :: iodata()
  def encode(value, options) do
    value
    |> Map.from_struct()
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> Poison.Encoder.encode(options)
  end
end
