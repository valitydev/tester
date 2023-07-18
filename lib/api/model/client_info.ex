defmodule Tester.Api.Model.ClientInfo do
  @derive [Tester.Api.Transformer]
  defstruct [
    :fingerprint,
    :ip
  ]

  @type t() :: %__MODULE__{
          :fingerprint => String.t(),
          :ip => String.t() | nil
        }
end

defimpl Poison.Encoder, for: Tester.Api.Model.ClientInfo do
  alias Tester.Api.Model

  @spec encode(Model.ClientInfo.t(), Poison.Encoder.options()) :: iodata()
  def encode(value, options) do
    value
    |> Map.from_struct()
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
    |> Poison.Encoder.encode(options)
  end
end
