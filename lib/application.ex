defmodule Tester.Application do
  use Application

  alias Tester.Config
  alias Tester.Runner.Manager

  def start(_type, _args) do
    flows = Config.get_flows()

    children =
      case Application.get_env(:tester, :start_workers, true) do
        true ->
          for {k, v} <- flows, do: make_child(k, v)

        false ->
          []
      end

    Supervisor.start_link(children, name: __MODULE__, strategy: :one_for_one)
  end

  @spec make_child(Config.name(), Config.options()) :: Supervisor.child_spec()
  defp make_child(name, options) do
    manager_options = %{
      name: name,
      flow: options[:flow],
      auth_options: options[:auth],
      payment_api_options: options[:payment_api],
      flow_pre_options: options[:options],
      interval: options[:interval]
    }

    %{
      id: name,
      start: {Manager.Supervisor, :start_link, [manager_options]}
    }
  end
end
