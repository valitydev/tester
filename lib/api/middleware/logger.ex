defmodule Tester.Api.Middleware.Logger do
  @behaviour Tesla.Middleware

  require Logger

  @type log_level :: :debug | :info | :warn | :error

  @impl Tesla.Middleware
  def call(env, next, opts) do
    level = Keyword.get(opts, :level, :debug)

    meta = [{:body, env.body} | env_opts(env)]
    Logger.log(level, "Calling #{env.method} #{env.url}", meta)

    {time, response} = :timer.tc(Tesla, :run, [env, next])

    milliseconds = System.convert_time_unit(time, :microsecond, :millisecond)
    meta = [{:response_time, milliseconds}, {:body, body(response)} | meta]
    Logger.log(level, "Received #{status(response)}", meta)

    response
  end

  defp env_opts(env) do
    Keyword.take(env.opts, [:request_id])
  end

  defp status({:ok, %Tesla.Env{status: status}}), do: status
  defp status({:error, error}), do: error

  defp body({:ok, %Tesla.Env{body: body}}), do: body
  defp body(_), do: nil
end
