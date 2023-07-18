defmodule Tester.Cli do
  require Logger
  alias Tester.Config
  alias Tester.Flow

  def main(_args) do
    flows = Config.get_flows()
    {flow, pre_options} = prepare_options(flows[:default_flow])
    result = run_flow(flow, pre_options)
    Logger.info("Finished with #{result}")
  end

  defp run_flow(flow, pre_options) do
    options = Flow.prepare(flow, pre_options)
    state = Flow.init(flow, options)
    run_flow_steps(flow, state)
  end

  defp run_flow_steps(flow, state) do
    result = Flow.process(flow, state)

    case result.intent do
      :continue ->
        run_flow_steps(flow, result.new_state)

      {:wait, timeout} ->
        :ok = Process.sleep(timeout)
        run_flow_steps(flow, result.new_state)

      :success = result ->
        result

      :fail = result ->
        result
    end
  end

  @spec prepare_options(Config.options()) :: {Flow.flow(), Flow.preparation_options()}
  defp prepare_options(options) do
    auth_options = options[:auth]

    {:ok, api_key} =
      Tester.Auth.get_api_key(auth_options[:user], auth_options[:password], auth_options)

    client = Tester.Api.Client.new(options[:payment_api])

    additional_options = %{
      client: client,
      api_key: api_key
    }

    {options[:flow], Map.merge(additional_options, options[:options])}
  end
end
