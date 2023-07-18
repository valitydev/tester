defmodule Tester.Api.Model.Reason do
  @derive [Tester.Api.Transformer]
  defstruct [
    :reason
  ]

  @type t() :: %__MODULE__{
          :reason => String.t()
        }
end
