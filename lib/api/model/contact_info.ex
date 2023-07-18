defmodule Tester.Api.Model.ContactInfo do
  @derive [Tester.Api.Transformer]
  defstruct [
    :email,
    :phoneNumber
  ]

  @type t() :: %__MODULE__{
          :email => String.t() | nil,
          :phoneNumber => String.t() | nil
        }
end

defimpl Poison.Encoder, for: Tester.Api.Model.ContactInfo do
  alias Tester.Api.Model

  @spec encode(Model.ContactInfo.t(), Poison.Encoder.options()) :: iodata()
  def encode(value, options) do
    value
    |> Map.from_struct()
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> Poison.Encoder.encode(options)
  end
end
