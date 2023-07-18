defmodule Tester.Flow.Payment.State do
  alias Tester.Api.Model

  defstruct [
    :client,
    :api_key,
    :party_id,
    :shop_id,
    :trace_id,
    :deadline,
    :bank_card,
    :amount,
    :currency,
    :invoice_id,
    :invoice_token,
    :payment_resource,
    :payment_id,
    :payment_status,
    :invoice_status,
    :retry_policy,
    :request_timeout
  ]

  @type t() :: %__MODULE__{
          :client => Tester.Api.Client.t(),
          :api_key => String.t(),
          :party_id => String.t(),
          :shop_id => String.t(),
          :trace_id => String.t(),
          :deadline => DateTime.t(),
          :bank_card => Model.CardData.t(),
          :amount => integer(),
          :request_timeout => timeout(),
          :currency => String.t(),
          :invoice_id => String.t() | nil,
          :invoice_token => String.t() | nil,
          :payment_resource => Model.PaymentResource.t() | nil,
          :payment_id => String.t() | nil,
          :payment_status => String.t() | nil,
          :invoice_status => String.t() | nil
        }
end
