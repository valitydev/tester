defmodule Tester.Api.Model.Payment do
  alias Tester.Api.Model.PaymentFlow
  alias Tester.Api.Model.Payer
  alias Tester.Api.Model.PaymentError

  defstruct [
    :id,
    :externalID,
    :invoiceID,
    :createdAt,
    :amount,
    :currency,
    :flow,
    :payer,
    :metadata,
    :status,
    :error
  ]

  @type t() :: %__MODULE__{
          :id => String.t(),
          :externalID => String.t() | nil,
          :invoiceID => String.t(),
          :createdAt => DateTime.t(),
          :amount => integer(),
          :currency => String.t(),
          :flow => PaymentFlow.variants(),
          :payer => Payer.variants(),
          :metadata => map() | nil,
          :status => String.t() | nil,
          :error => PaymentError.t() | nil
        }
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.Payment do
  alias Tester.Api.Model
  alias Tester.Api.Transform

  @spec transform(Model.Payment.t(), map()) :: Model.Payment.t()
  def transform(type, value) do
    Transform.transform_with_fields(type, value,
      flow: %Model.PaymentFlow{},
      payer: %Model.Payer{}
    )
  end
end
