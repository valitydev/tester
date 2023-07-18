defmodule Tester.Api.Model.Invoice do
  @derive [Tester.Api.Transformer]
  defstruct [
    :id,
    :shopID,
    :externalID,
    :createdAt,
    :dueDate,
    :amount,
    :currency,
    :product,
    :description,
    :invoiceTemplateID,
    :metadata,
    :status,
    :reason
  ]

  @type t() :: %__MODULE__{
          :id => String.t(),
          :shopID => String.t(),
          :externalID => String.t() | nil,
          :createdAt => DateTime.t(),
          :dueDate => DateTime.t(),
          :amount => integer(),
          :currency => String.t(),
          :product => String.t(),
          :description => String.t() | nil,
          :metadata => map(),
          :status => String.t() | nil,
          :reason => String.t() | nil
        }
end
