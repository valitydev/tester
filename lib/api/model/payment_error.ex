defmodule Tester.Api.Model.PaymentError do
  alias Tester.Api.Model.SubError

  defstruct [
    :code,
    :subError
  ]

  @type t() :: %__MODULE__{
          :code => String.t(),
          :subError => SubError.t() | nil
        }
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.PaymentError do
  alias Tester.Api.Model
  alias Tester.Api.Transform

  @spec transform(Model.PaymentError.t(), map()) :: Model.PaymentError.t()
  def transform(type, value) do
    Transform.transform_with_fields(type, value, subError: %Model.SubError{})
  end
end
