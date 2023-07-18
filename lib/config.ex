defmodule Tester.Config do
  alias Tester.Api.Model
  alias Tester.Flow

  @type flows() :: %{name() => options()}
  @type name() :: atom()
  @type options() :: %{
          :interval => timeout(),
          :auth => auth_options(),
          :payment_api => Tester.Api.Client.options(),
          :flow => Flow.flow(),
          :options => flow_options()
        }
  @type flow_options() :: %{
          :bank_card => Model.CardData.t(),
          atom() => term()
        }
  @type auth_options() :: %{
          :user => String.t(),
          :password => String.t(),
          :base_url => String.t(),
          :realm => String.t()
        }
  @type bank_card_options() :: %{
          :card_number => String.t(),
          :exp_date => String.t(),
          :cvv => String.t(),
          :card_holder => String.t()
        }

  @spec get_flows() :: flows()
  def get_flows() do
    for {k, v} <- Application.fetch_env!(:tester, :flows), into: %{} do
      {k, prepare_options(v)}
    end
  end

  defp prepare_options(options) do
    Map.update!(options, :options, &prepare_flow_options(&1))
  end

  defp prepare_flow_options(options) do
    Map.update!(options, :bank_card, &build_card(&1))
  end

  @spec build_card(bank_card_options()) :: Model.CardData.t()
  defp build_card(options) do
    %Model.CardData{
      cardNumber: options[:card_number],
      expDate: options[:exp_date],
      cvv: options[:cvv],
      cardHolder: options[:card_holder]
    }
  end
end
