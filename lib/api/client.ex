defmodule Tester.Api.Client do
  use Tesla

  plug(Tester.Api.Middleware.Auth)
  plug(Tester.Api.Middleware.RequestId)
  plug(Tester.Api.Middleware.Deadline)
  plug(Tester.Api.Middleware.ErrorHandler, filter_opts: [:api_key])
  plug(Tester.Api.Middleware.Logger)

  @type t() :: Tesla.Env.client()
  @type options() :: %{
          :base_url => String.t(),
          :origin => String.t()
        }

  @spec new(options()) :: t
  def new(options) do
    middleware = [
      {Tesla.Middleware.BaseUrl, options[:base_url]},
      {Tesla.Middleware.Headers, [{"User-agent", "Tester"},{"Origin", options[:origin]}]}
    ]

    adapter = {Tesla.Adapter.Gun, []}
    Tesla.client(middleware, adapter)
  end
end
