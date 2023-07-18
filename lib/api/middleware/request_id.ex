defmodule Tester.Api.Middleware.RequestId do
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, _opts) do
    request_id = make_id(env.opts[:request_id])

    env
    |> Tesla.put_headers(header(request_id))
    |> Tesla.put_opt(:request_id, request_id)
    |> Tesla.run(next)
  end

  defp make_id(nil) do
    Tester.Util.make_random_string()
  end

  defp make_id(request_id) when is_binary(request_id) do
    request_id
  end

  defp header(request_id) do
    [{"X-Request-ID", request_id}]
  end
end
