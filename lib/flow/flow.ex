defmodule Tester.Flow do
  alias Tester.Flow.Result

  @type flow :: module()
  @type preparation_options :: term()
  @type options :: term()
  @type state :: term()
  @type result :: Result.t()

  @callback prepare(preparation_options) :: options()
  @callback init(options) :: state()
  @callback process(state) :: result()

  @spec prepare(flow(), preparation_options()) :: options()
  def prepare(implementation, preparation_options) do
    implementation.prepare(preparation_options)
  end

  @spec init(flow(), options()) :: state()
  def init(implementation, options) do
    implementation.init(options)
  end

  @spec process(flow(), state()) :: result()
  def process(implementation, state) do
    implementation.process(state)
  end
end

defmodule Tester.Flow.Result do
  defstruct [
    :new_state,
    intent: :continue
  ]

  @type t() :: %__MODULE__{
          :new_state => term(),
          :intent => intent()
        }
  @type intent() :: :continue | :success | :fail | {:wait, timeout()}
end
