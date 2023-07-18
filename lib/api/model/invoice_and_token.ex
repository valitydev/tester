defmodule Tester.Api.Model.InvoiceAndToken do
  alias Tester.Api.Model.AccessToken
  alias Tester.Api.Model.Invoice

  defstruct [
    :invoice,
    :invoiceAccessToken
  ]

  @type t() :: %__MODULE__{
          :invoice => Invoice.t(),
          :invoiceAccessToken => AccessToken.t()
        }
end

defimpl Tester.Api.Transformer, for: Tester.Api.Model.InvoiceAndToken do
  alias Tester.Api.Model
  alias Tester.Api.Transform

  @spec transform(Model.InvoiceAndToken.t(), map()) :: Model.InvoiceAndToken.t()
  def transform(type, value) do
    Transform.transform_with_fields(type, value,
      invoice: %Model.Invoice{},
      invoiceAccessToken: %Model.AccessToken{}
    )
  end
end
