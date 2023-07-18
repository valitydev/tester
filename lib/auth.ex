defmodule Tester.Auth do
  alias Tester.Auth.Client

  @type options() :: %{
          :base_url => String.t(),
          :realm => String.t()
        }

  @spec get_api_key(String.t(), String.t(), options()) ::
          {:ok, String.t()} | {:error, any()}
  def get_api_key(username, password, options) do
    client = Client.new(make_client_options(options))

    body = %{
      username: username,
      password: password,
      client_id: "common-api",
      grant_type: "password"
    }

    realm = options[:realm]
    url = "/auth/realms/#{realm}/protocol/openid-connect/token"

    with(
      {:ok, response} <- Client.post(client, url, body),
      {:ok, body} <- Client.get_body(response),
      {:ok, result} <- Poison.decode(body)
    ) do
      {:ok, Map.get(result, "access_token")}
    end
  end

  @spec make_client_options(options()) :: Client.options()
  defp make_client_options(options) do
    %{
      :base_url => options[:base_url]
    }
  end
end

defmodule Tester.Auth.Client do
  use Tesla

  plug(Tesla.Middleware.FormUrlencoded)

  @type t() :: Tesla.Env.client()
  @type options() :: %{
          :base_url => String.t()
        }

  @spec new(options()) :: t()
  def new(options) do
    middleware = [
      {Tesla.Middleware.BaseUrl, options[:base_url]}
    ]

    adapter = {Tesla.Adapter.Gun, []}
    Tesla.client(middleware, adapter)
  end

  @spec get_body(Tesla.Env.t()) :: {:ok, String.t()} | {:error, any}
  def get_body(%Tesla.Env{status: 200, body: body}) do
    {:ok, body}
  end

  def get_body(%Tesla.Env{status: status, body: body}) do
    {:error, {:unexpected_response, status, body}}
  end
end
