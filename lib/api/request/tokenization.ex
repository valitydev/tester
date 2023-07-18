defmodule Tester.Api.Request.Tokenzation do
  alias Tester.Api.Client
  alias Tester.Api.Error
  alias Tester.Api.Model.PaymentResourceParams
  alias Tester.Api.Model.PaymentResource

  import Tester.Api.RequestBuilder

  @spec create_payment_resource(Client.t(), String.t(), PaymentResourceParams.t(), Keyword.t()) ::
          {:ok, PaymentResource.t()} | {:error, Error.t()}
  def create_payment_resource(client, api_key, params, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:post)
    |> set_url("/processing/payment-resources")
    |> set_api_key(api_key)
    |> set_body(params)
    |> request(client)
    |> decode(%PaymentResource{})
  end
end
