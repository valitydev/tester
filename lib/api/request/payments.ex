defmodule Tester.Api.Request.Payment do
  alias Tester.Api.Client
  alias Tester.Api.Error
  alias Tester.Api.Model.{Payment, PaymentParams}

  import Tester.Api.RequestBuilder

  @spec create_payment(Client.t(), String.t(), String.t(), PaymentParams.t(), Keyword.t()) ::
          {:ok, Payment.t()} | {:error, Error.t()}
  def create_payment(client, api_key, invoice_id, params, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:post)
    |> set_url("/processing/invoices/#{invoice_id}/payments")
    |> set_api_key(api_key)
    |> set_body(params)
    |> request(client)
    |> decode(%Payment{})
  end

  @spec get_payment_by_id(Client.t(), String.t(), String.t(), String.t(), Keyword.t()) ::
          {:ok, Payment.t()} | {:error, Error.t()}
  def get_payment_by_id(client, api_key, invoice_id, payment_id, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:get)
    |> set_url("/processing/invoices/#{invoice_id}/payments/#{payment_id}")
    |> set_api_key(api_key)
    |> request(client)
    |> decode(%Payment{})
  end
end
