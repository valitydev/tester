defmodule Tester.Flow.Payment do
  @behaviour Tester.Flow

  alias Tester.Util
  alias Tester.Deadline
  alias Tester.Flow.Result
  alias Tester.Api.Model
  alias Tester.Api.Request
  alias Tester.Flow.Payment.State

  @type preparation_options() :: %{
          :client => Tester.Api.Client.t(),
          :api_key => String.t(),
          :bank_card => Model.CardData.t(),
          :amount => integer(),
          :currency => String.t(),
          :request_timeout => timeout()
        }
  @type options() :: %{
          :client => Tester.Api.Client.t(),
          :api_key => String.t(),
          :party_id => String.t(),
          :shop_id => String.t(),
          :bank_card => Model.CardData.t(),
          :amount => integer(),
          :currency => String.t(),
          :request_timeout => timeout(),
          optional(:deadline) => DateTime.t(),
          optional(:trace_id) => String.t()
        }
  @type state() :: State.t()
  @type result() :: Result.t()

  @typep activity() ::
           :make_invoice
           | :tokenize
           | :make_payment
           | :wait_successful_payment
           | :wait_paid_invoice
           | :report_success

  @impl Tester.Flow
  @spec prepare(preparation_options()) :: options()
  def prepare(options) do
    api_key = options[:api_key]
    client = options[:client]
    {:ok, party} = Request.Party.get_my_party(client, api_key, request_options(options))

    {:ok, shops} =
      Request.Shop.get_shops_for_party(client, api_key, party.id, request_options(options))

    [shop] = shops
    Map.merge(options, %{party_id: party.id, shop_id: shop.id})
  end

  @impl Tester.Flow
  @spec init(options()) :: state()
  def init(options) do
    additional_options = %{
      trace_id: Util.make_random_string(),
      deadline: Deadline.make_deadline(600, :second)
    }

    options = Map.merge(additional_options, options)

    %State{
      client: options[:client],
      api_key: options[:api_key],
      party_id: options[:party_id],
      shop_id: options[:shop_id],
      trace_id: options[:trace_id],
      deadline: options[:deadline],
      bank_card: options[:bank_card],
      amount: options[:amount],
      currency: options[:currency],
      request_timeout: options[:request_timeout]
    }
  end

  @impl Tester.Flow
  @spec process(state()) :: result()
  def process(state) do
    with :ok <- check_deadline(state) do
      process(deduce_activity(state), state)
    else
      {:error, _reason} ->
        %Result{new_state: state, intent: :fail}
    end
  end

  defguardp is_final_payment_status(status) when status == "captured" or status == "failed"

  defguardp is_final_invoice_status(status) when status == "paid" or status == "fulfilled"

  @spec process(activity(), state()) :: result()
  defp process(:make_invoice, state) do
    params = %Model.InvoiceParams{
      shopID: state.shop_id,
      partyID: state.party_id,
      externalID: state.trace_id,
      amount: state.amount,
      currency: state.currency,
      product: "Rubber duck",
      dueDate: state.deadline,
      description: "Hello",
      metadata: %{}
    }

    {:ok, res} =
      Request.Invoice.create_invoice(state.client, state.api_key, params, request_options(state))

    %Result{
      new_state: %State{
        state
        | invoice_id: res.invoice.id,
          invoice_token: res.invoiceAccessToken.payload
      }
    }
  end

  defp process(:tokenize, state) do
    params = %Model.PaymentResourceParams{
      externalID: state.trace_id,
      paymentTool: state.bank_card,
      clientInfo: %Model.ClientInfo{fingerprint: "kek"}
    }

    {:ok, res} =
      Request.Tokenzation.create_payment_resource(
        state.client,
        state.invoice_token,
        params,
        request_options(state)
      )

    %Result{new_state: %State{state | payment_resource: res}}
  end

  defp process(:make_payment, state) do
    params = %Model.PaymentParams{
      externalID: state.trace_id,
      flow: %Model.PaymentFlowInstant{},
      payer: %Model.PaymentResourcePayer{
        paymentToolToken: state.payment_resource.paymentToolToken,
        paymentSession: state.payment_resource.paymentSession,
        contactInfo: %Model.ContactInfo{}
      },
      processingDeadline: "30s"
    }

    {:ok, payment} =
      Request.Payment.create_payment(
        state.client,
        state.invoice_token,
        state.invoice_id,
        params,
        request_options(state)
      )

    %Result{new_state: %State{state | payment_id: payment.id}}
  end

  defp process(:wait_successful_payment, state) do
    {:ok, payment} =
      Request.Payment.get_payment_by_id(
        state.client,
        state.invoice_token,
        state.invoice_id,
        state.payment_id,
        request_options(state)
      )

    intent =
      case payment do
        %Model.Payment{status: "failed"} ->
          :fail

        %Model.Payment{status: status} when is_final_payment_status(status) ->
          :continue

        _other ->
          {:wait, 100}
      end

    %Result{intent: intent, new_state: %State{state | payment_status: payment.status}}
  end

  defp process(:wait_paid_invoice, state) do
    {:ok, invoice} =
      Request.Invoice.get_invoice_by_id(
        state.client,
        state.api_key,
        state.invoice_id,
        request_options(state)
      )

    intent =
      case invoice do
        %Model.Invoice{status: status} when is_final_invoice_status(status) ->
          :continue

        _other ->
          {:wait, 100}
      end

    %Result{intent: intent, new_state: %State{state | invoice_status: invoice.status}}
  end

  defp process(:report_success, state) do
    %Result{new_state: state, intent: :success}
  end

  @spec deduce_activity(state()) :: activity()
  defp deduce_activity(%State{invoice_id: nil}) do
    :make_invoice
  end

  defp deduce_activity(%State{payment_resource: nil}) do
    :tokenize
  end

  defp deduce_activity(%State{payment_id: nil}) do
    :make_payment
  end

  defp deduce_activity(%State{payment_status: status}) when not is_final_payment_status(status) do
    :wait_successful_payment
  end

  defp deduce_activity(%State{invoice_status: status}) when not is_final_invoice_status(status) do
    :wait_paid_invoice
  end

  defp deduce_activity(_state) do
    :report_success
  end

  @spec check_deadline(state()) :: :ok | {:error, :deadline_reached}
  defp check_deadline(state) do
    case Deadline.is_reached(state.deadline) do
      true -> :ok
      false -> {:error, :deadline_reached}
    end
  end

  defp request_options(%{request_timeout: request_timeout}) do
    [deadline: Deadline.from_timeout(request_timeout)]
  end
end
