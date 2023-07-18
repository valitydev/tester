defmodule Tester.Api.Model.InvoiceParams do
  @derive [Tester.Api.Transformer]
  defstruct [
    :shopID,
    :partyID,
    :externalID,
    :dueDate,
    :amount,
    :currency,
    :product,
    :description,
    :metadata
  ]

  @type t() :: %__MODULE__{
          :shopID => String.t(),
          :partyID => String.t() | nil,
          :externalID => String.t() | nil,
          :dueDate => DateTime.t(),
          :amount => integer() | nil,
          :currency => String.t(),
          :product => String.t(),
          :description => String.t(),
          :metadata => map()
        }
end
