defmodule Tester.Api.RequestBuilder do
  alias Tester.Api.Client
  alias Tester.Api.Error
  alias Tester.Api.Transformer
  alias Tester.Api.Middleware.ErrorHandler

  @opaque t() :: map()
  @type result_type() :: struct | [struct]

  @spec new_request() :: t()
  def new_request() do
    new_request([])
  end

  @spec new_request(Keyword.t()) :: t()
  def new_request(opts) do
    %{opts: opts}
  end

  @spec set_method(t(), atom) :: t()
  def set_method(request, m) do
    Map.put(request, :method, m)
  end

  @spec set_url(t(), String.t()) :: t()
  def set_url(request, u) do
    Map.put(request, :url, u)
  end

  @spec set_request_id(t(), String.t()) :: t()
  def set_request_id(request, id) do
    add_opt(request, :request_id, id)
  end

  @spec set_api_key(t(), String.t()) :: t()
  def set_api_key(request, api_key) do
    add_opt(request, :api_key, api_key)
  end

  @spec set_body(t(), struct()) :: t()
  def set_body(request, value) do
    request
    |> add_header("Content-Type", "application/json; charset=utf-8")
    |> Map.put(:body, Poison.encode!(value))
  end

  @spec add_optional_params(t(), %{optional(atom) => atom}, keyword()) :: t()
  def add_optional_params(request, _, []), do: request

  def add_optional_params(request, definitions, [{key, value} | tail]) do
    case definitions do
      %{^key => location} ->
        request
        |> add_param(location, key, value)
        |> add_optional_params(definitions, tail)

      _ ->
        add_optional_params(request, definitions, tail)
    end
  end

  @spec add_param(t(), atom(), atom(), String.t()) :: t()
  def add_param(request, location, key, value) do
    Map.update(request, location, [{key, value}], &(&1 ++ [{key, value}]))
  end

  @spec request(t(), Client.t()) :: {:ok, Tesla.Env.t()} | {:error, Error.t()}
  def request(request, client) do
    Client.request(client, Enum.into(request, []))
  end

  @spec decode({:ok, Tesla.Env.t()} | {:error, ErrorHandler.Error.t()}) ::
          :ok | {:error, Error.t()}
  def decode({:ok, env}) do
    case env do
      %Tesla.Env{status: status} when status < 300 ->
        :ok

      %Tesla.Env{status: status} when status >= 300 ->
        {:error, make_http_error(env)}
    end
  end

  def decode({:error, reason}) do
    {:error, make_transport_error(reason)}
  end

  @spec decode({:ok, Tesla.Env.t()} | {:error, ErrorHandler.Error.t()}, result_type()) ::
          {:ok, result_type()} | {:error, Error.t()}
  def decode({:ok, env}, result_type) do
    decode_env(env, result_type)
  end

  def decode({:error, reason}, _result_type) do
    {:error, make_transport_error(reason)}
  end

  @spec add_opt(t(), term(), term()) :: map()
  defp add_opt(request, name, value) do
    request
    |> Map.put_new(:opts, [])
    |> Map.update!(:opts, &[{name, value} | &1])
  end

  @spec add_header(t(), String.t(), String.t()) :: map()
  defp add_header(request, key, value) do
    request
    |> Map.put_new(:headers, [])
    |> Map.update!(:headers, &[{key, value} | &1])
  end

  @spec decode(Tesla.Env.t(), result_type()) :: {:ok, result_type()} | {:error, Error.t()}
  defp decode_env(%Tesla.Env{status: status, body: body}, result_type)
       when status >= 200 and status < 300 do
    json_data = Poison.Parser.parse!(body, %{})
    decoded_data = Transformer.transform(result_type, json_data) |> Poison.Decoder.decode(%{})
    {:ok, decoded_data}
  end

  defp decode_env(%Tesla.Env{status: status} = env, _result_type) when status >= 300 do
    {:error, make_http_error(env)}
  end

  defp make_transport_error(%ErrorHandler.Error{error: error, opts: opts}) do
    {type, class} = classify_transport_reason(error)

    %Error{
      type: type,
      class: class,
      source: :internal,
      details: error,
      request_id: opts[:request_id]
    }
  end

  defp make_http_error(%Tesla.Env{status: status, body: body, opts: opts})
       when status >= 300 and status < 500 do
    {type, class} = classify_http_code(status)

    %Error{
      type: type,
      class: class,
      source: :external,
      status: status,
      details: body,
      request_id: opts[:request_id]
    }
  end

  defp make_http_error(%Tesla.Env{status: status, opts: opts}) when status >= 500 do
    {type, class} = classify_http_code(status)

    %Error{
      type: type,
      class: class,
      source: :external,
      status: status,
      request_id: opts[:request_id]
    }
  end

  defp classify_http_code(429), do: {:system, :resource_unavailable}
  defp classify_http_code(504), do: {:system, :result_unknown}
  defp classify_http_code(_code), do: {:business, :result_unexpected}

  defp classify_transport_reason(:recv_response_timeout), do: {:system, :result_unknown}
  defp classify_transport_reason(:recv_chunk_timeout), do: {:system, :result_unknown}
  defp classify_transport_reason(:invalid_conn), do: {:system, :result_unexpected}
  defp classify_transport_reason(_reason), do: {:system, :resource_unavailable}
end
