defmodule Tester.Runner.Worker.State do
  alias Tester.Flow

  defstruct [
    :flow,
    :flow_state,
    :timer
  ]

  @type t() :: %__MODULE__{
          :flow => Flow.flow(),
          :flow_state => Flow.state(),
          :timer => reference() | nil
        }
end

defmodule Tester.Runner.Worker do
  use GenServer, restart: :temporary

  require Logger
  alias Tester.Runner.Worker.State
  alias Tester.Flow

  @type options() :: %{
          :flow => Flow.flow(),
          :flow_options => flow_options()
        }
  @type flow_options() :: %{atom() => term()}
  @typep state() :: State.t()

  @spec start_link(options()) :: GenServer.on_start()
  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  @impl true
  @spec init(options()) :: {:ok, state()}
  def init(%{flow: flow, flow_options: options}) do
    flow_state = Flow.init(flow, options)
    state = %State{flow: flow, flow_state: flow_state} |> schedule_processing(0)
    {:ok, state}
  end

  @impl true
  @spec handle_info(term(), state()) :: {:noreply, state()} | {:stop, term(), state()}
  def handle_info(:process, state) do
    result = Flow.process(state.flow, state.flow_state)
    new_state = %State{state | flow_state: result.new_state}

    case result.intent do
      :continue ->
        {:noreply, schedule_processing(new_state, 0)}

      {:wait, timeout} ->
        {:noreply, schedule_processing(new_state, timeout)}

      :success ->
        {:stop, :normal, new_state}

      :fail ->
        {:stop, :normal, new_state}
    end
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
end

defmodule Tester.Runner.Worker.Supervisor do
  use DynamicSupervisor

  @type name() :: atom()

  @spec start_link(name()) :: Supervisor.on_start()
  def start_link(name) do
    DynamicSupervisor.start_link(__MODULE__, [], name: name)
  end

  @spec add_worker(name(), Tester.Runner.Worker.options()) :: DynamicSupervisor.on_start_child()
  def add_worker(name, worker_options) do
    DynamicSupervisor.start_child(name, {Tester.Runner.Worker, worker_options})
  end

  @impl true
  @spec init(any()) :: {:ok, DynamicSupervisor.sup_flags()}
  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
