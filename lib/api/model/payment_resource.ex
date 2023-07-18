defmodule Tester.Api.Model.PaymentResource do
  alias Tester.Api.Model.PaymentToolDetails
  alias Tester.Api.Model.ClientInfo

  defstruct [
    :paymentToolToken,
    :paymentSession,
    :paymentToolDetails,
    :clientInfo,
    :validUntil
  ]

  @type t() :: %__MODULE__{
          :paymentToolToken => String.t(),
          :paymentSession => String.t(),
          :paymentToolDetails => PaymentToolDetails.t() | nil,
          :clientInfo => ClientInfo.t() | nil,
          :validUntil => DateTime.t() | nil
        }
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.PaymentResource do
  alias Tester.Api.Model
  alias Tester.Api.Transform

  @spec transform(Model.PaymentResource.t(), map()) :: Model.PaymentResource.t()
  def transform(type, value) do
    Transform.transform_with_fields(type, value,
      paymentToolDetails: %Model.PaymentToolDetails{},
      clientInfo: %Model.ClientInfo{}
    )
  end
end
