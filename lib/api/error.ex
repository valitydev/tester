defmodule Tester.Api.Error do
  defstruct [
    :type,
    :class,
    :source,
    :status,
    :request_id,
    :details
  ]

  @type error_type() :: :business | :system
  @type error_class() :: :resource_unavailable | :result_unexpected | :result_unknown
  @type error_source() :: :internal | :external

  @type t() :: %__MODULE__{
          :type => error_type(),
          :class => error_class(),
          :source => error_source(),
          :status => pos_integer(),
          :request_id => String.t(),
          :details => term()
        }
end
