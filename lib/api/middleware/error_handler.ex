defmodule Tester.Api.Middleware.ErrorHandler.Error do
  defstruct [
    :error,
    :opts
  ]

  @type t() :: %__MODULE__{
          :error => term(),
          :opts => Keyword.t()
        }
end

defmodule Tester.Api.Middleware.ErrorHandler do
  @behaviour Tesla.Middleware

  alias Tester.Api.Middleware.ErrorHandler.Error

  @impl Tesla.Middleware
  def call(env, next, opts) do
    env
    |> Tesla.run(next)
    |> handle_result(env.opts, opts)
  end

  defp handle_result({:ok, _} = response, _env_opts, _opts) do
    response
  end

  defp handle_result({:error, error}, env_opts, opts) do
    filtered = Keyword.get(opts, :filter_opts, [])
    {:error, %Error{error: error, opts: Keyword.drop(env_opts, filtered)}}
  end
end
