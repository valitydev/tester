defmodule Tester.Api.Request.Shop do
  alias Tester.Api.Client
  alias Tester.Api.Error
  alias Tester.Api.Model.Shop

  import Tester.Api.RequestBuilder

  @spec get_shops_for_party(Client.t(), String.t(), String.t(), Keyword.t()) ::
          {:ok, [Shop.t()]} | {:error, Error.t()}
  def get_shops_for_party(client, api_key, party_id, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:get)
    |> set_url("/processing/parties/#{party_id}/shops")
    |> set_api_key(api_key)
    |> request(client)
    |> decode([%Shop{}])
  end
end
