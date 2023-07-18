defmodule Tester.Api.Model.SubError do
  defstruct [
    :code,
    :subError
  ]

  @type t() :: %__MODULE__{
          :code => String.t(),
          :subError => __MODULE__.t() | nil
        }
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.SubError do
  alias Tester.Api.Model
  alias Tester.Api.Transform

  @spec transform(Model.SubError.t(), map()) :: Model.SubError.t()
  def transform(type, value) do
    Transform.transform_with_fields(type, value, subError: %Model.SubError{})
  end
end
