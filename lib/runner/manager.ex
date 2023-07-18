defmodule Tester.Runner.Manager.State do
  alias Tester.Flow
  alias Tester.Config

  defstruct [
    :name,
    :flow,
    :flow_pre_options,
    :flow_options,
    :auth_options,
    :payment_api_options,
    :interval,
    :timer
  ]

  @type t() :: %__MODULE__{
          :name => atom(),
          :flow => Flow.flow(),
          :flow_pre_options => Config.flow_options(),
          :interval => timeout(),
          :flow_options => Tester.Runner.Worker.flow_options() | nil,
          :auth_options => Config.auth_options(),
          :payment_api_options => Tester.Api.Client.options(),
          :timer => reference() | nil
        }
end

defmodule Tester.Runner.Manager do
  use GenServer

  require Logger
  alias Tester.Runner.Manager.State
  alias Tester.Flow
  alias Tester.Config

  @type options() :: %{
          :name => atom(),
          :flow => Flow.flow(),
          :flow_pre_options => Config.flow_options(),
          :auth_options => Config.auth_options(),
          :payment_api_options => Tester.Api.Client.options(),
          :interval => timeout()
        }

  @typep state() :: State.t()

  @spec start_link(options()) :: GenServer.on_start()
  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  @impl true
  @spec init(options()) :: {:ok, state(), {:continue, term()}}
  def init(options) do
    state = %State{
      name: options[:name],
      flow: options[:flow],
      auth_options: options[:auth_options],
      payment_api_options: options[:payment_api_options],
      flow_pre_options: options[:flow_pre_options],
      interval: options[:interval]
    }

    {:ok, state, {:continue, :prepare_options}}
  end

  @impl true
  @spec handle_continue(term(), state()) :: {:noreply, state()}
  def handle_continue(:prepare_options, state) do
    auth = state.auth_options

    {:ok, api_key} =
      Tester.Auth.get_api_key(auth[:user], auth[:password], make_auth_api_options(auth))

    additional_options = %{
      client: Tester.Api.Client.new(state.payment_api_options),
      api_key: api_key
    }

    options = Flow.prepare(state.flow, Map.merge(additional_options, state.flow_pre_options))
    {:noreply, schedule_processing(%State{state | flow_options: options}, 0)}
  end

  @impl true
  @spec handle_info(term(), state()) :: {:noreply, state()} | {:stop, term(), state()}
  def handle_info(:process, state) do
    worker_options = %{flow: state.flow, flow_options: state.flow_options}
    {:ok, _pid} = Tester.Runner.Worker.Supervisor.add_worker(state.name, worker_options)
    {:noreply, schedule_processing(state, state.interval)}
  end

  def handle_info(other, state) do
    Logger.warn("Unexpected message #{other}")
    {:noreply, state}
  end

  @spec schedule_processing(state(), timeout()) :: state()
  defp schedule_processing(state, timeout) do
    new_state = cancel_processing(state)
    ref = Process.send_after(self(), :process, timeout)
    %State{new_state | timer: ref}
  end

  @spec cancel_processing(state()) :: state()
  defp cancel_processing(%State{timer: timer} = state) when is_nil(timer) do
    state
  end

  defp cancel_processing(%State{timer: timer} = state) when is_reference(timer) do
    _ = Process.cancel_timer(timer)
    %State{state | timer: nil}
  end

  @spec make_auth_api_options(Config.auth_options()) :: Tester.Auth.options()
  defp make_auth_api_options(auth_options) do
    %{
      realm: auth_options[:realm],
      base_url: auth_options[:base_url]
    }
  end
end

defmodule Tester.Runner.Manager.Supervisor do
  use Supervisor

  @type options() :: Tester.Runner.Manager.options()

  @spec start_link(options()) :: Supervisor.on_start()
  def start_link(options) do
    Supervisor.start_link(__MODULE__, options)
  end

  @impl true
  def init(options) do
    children = [
      {Tester.Runner.Manager, options},
      {Tester.Runner.Worker.Supervisor, options[:name]}
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
