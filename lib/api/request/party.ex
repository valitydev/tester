defmodule Tester.Api.Request.Party do
  alias Tester.Api.Client
  alias Tester.Api.Error
  alias Tester.Api.Model.Party

  import Tester.Api.RequestBuilder

  @spec get_my_party(Client.t(), String.t(), Keyword.t()) ::
          {:ok, Party.t()} | {:error, Error.t()}
  def get_my_party(client, api_key, opts \\ []) do
    opts
    |> new_request()
    |> set_method(:get)
    |> set_url("/processing/me")
    |> set_api_key(api_key)
    |> request(client)
    |> decode(%Party{})
  end
end
