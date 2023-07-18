defmodule Tester.Api.Middleware.Deadline do
  @behaviour Tesla.Middleware

  alias Tester.Deadline

  @impl Tesla.Middleware
  def call(env, next, _opts) do
    deadline = env.opts[:deadline]

    env
    |> Tesla.put_headers(deadline_headers(deadline))
    |> put_deadline_opts(deadline)
    |> Tesla.run(next)
  end

  defp deadline_headers(nil) do
    []
  end

  defp deadline_headers(deadline) do
    header_value = Deadline.to_iso8601(deadline)

    [{"X-Request-Deadline", header_value}]
  end

  defp put_deadline_opts(env, nil) do
    env
  end

  defp put_deadline_opts(env, deadline) do
    adapter_opts =
      env.opts
      |> Keyword.get(:adapter, [])
      |> add_deadline(deadline)

    Tesla.put_opt(env, :adapter, adapter_opts)
  end

  defp add_deadline(opts, deadline) do
    timeout = Deadline.to_timeout_or_zero(deadline)
    [{:timeout, timeout}, {:connect_timeout, timeout} | opts]
  end
end
