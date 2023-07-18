defmodule Tester.Api.Model.AccessToken do
  @derive [Tester.Api.Transformer]
  defstruct [
    :payload
  ]

  @type t() :: %__MODULE__{
          :payload => String.t()
        }
end
