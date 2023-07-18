defmodule Tester.Api.Request.Invoice do
  alias Tester.Api.Client
  alias Tester.Api.Error
  alias Tester.Api.Model.{Invoice, InvoiceParams, InvoiceAndToken, AccessToken, Reason}

  import Tester.Api.RequestBuilder

  @spec create_invoice(Client.t(), String.t(), InvoiceParams.t(), Keyword.t()) ::
          {:ok, InvoiceAndToken.t()} | {:error, Error.t()}
  def create_invoice(client, api_key, params, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:post)
    |> set_url("/processing/invoices")
    |> set_api_key(api_key)
    |> set_body(params)
    |> request(client)
    |> decode(%InvoiceAndToken{})
  end

  @spec create_invoice_access_token(Client.t(), String.t(), String.t(), Keyword.t()) ::
          {:ok, AccessToken.t()} | {:error, Error.t()}
  def create_invoice_access_token(client, api_key, invoice_id, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:post)
    |> set_url("/processing/invoices/#{invoice_id}/access-tokens")
    |> set_api_key(api_key)
    |> request(client)
    |> decode(%AccessToken{})
  end

  @spec fulfill_invoice(Tesla.Env.client(), String.t(), String.t(), Reason.t(), Keyword.t()) ::
          :ok | {:error, Error.t()}
  def fulfill_invoice(client, api_key, invoice_id, reason, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:post)
    |> set_url("/processing/invoices/#{invoice_id}/fulfill")
    |> set_api_key(api_key)
    |> set_body(reason)
    |> request(client)
    |> decode()
  end

  @spec get_invoice_by_external_id(Tesla.Env.client(), String.t(), String.t(), Keyword.t()) ::
          {:ok, Invoice.t()} | {:error, Error.t()}
  def get_invoice_by_external_id(client, api_key, external_id, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:get)
    |> set_url("/processing/invoices")
    |> set_api_key(api_key)
    |> add_param(:query, :externalID, external_id)
    |> request(client)
    |> decode(%Invoice{})
  end

  @spec get_invoice_by_id(Tesla.Env.client(), String.t(), String.t(), Keyword.t()) ::
          {:ok, Invoice.t()} | {:error, Error.t()}
  def get_invoice_by_id(client, api_key, invoice_id, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:get)
    |> set_url("/processing/invoices/#{invoice_id}")
    |> set_api_key(api_key)
    |> request(client)
    |> decode(%Invoice{})
  end
end
