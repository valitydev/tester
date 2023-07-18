defmodule Tester.Api.Middleware.Auth do
  @behaviour Tesla.Middleware

  @impl Tesla.Middleware
  def call(env, next, _opts) do
    api_key = env.opts[:api_key]

    env
    |> Tesla.put_headers(authorization_header(api_key))
    |> Tesla.run(next)
  end

  defp authorization_header(nil) do
    []
  end

  defp authorization_header(api_key) do
    [{"Authorization", "Bearer #{api_key}"}]
  end
end
