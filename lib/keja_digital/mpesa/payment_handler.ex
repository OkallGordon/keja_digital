 defmodule KejaDigital.Mpesa.PaymentHandler do
  require Logger
  alias KejaDigital.Payments
  alias KejaDigital.Store

  @till_number "4154742"

  def handle_callback(params) do
    Logger.info("Processing Mpesa payment: #{inspect(params)}")

    with {:ok, payment_data} <- extract_payment_data(params),
         :ok <- validate_till_number(payment_data),
         {:ok, tenant} <- find_tenant(payment_data) do

      create_payment(payment_data, tenant)
    else
      {:error, reason} = error ->
        Logger.error("Payment processing failed: #{inspect(reason)}")
        error
    end
  end

  defp extract_payment_data(params) do
    # Sample Mpesa callback data structure
    # Adjust these based on actual Mpesa callback format
    try do
      {:ok, %{
        transaction_id: params["TransID"],
        amount: Decimal.new(params["TransAmount"]),
        phone_number: clean_phone_number(params["MSISDN"]),
        till_number: params["BusinessShortCode"],
        bill_ref_number: params["BillRefNumber"],  # Door number
        transaction_date: parse_transaction_date(params["TransactionDate"])
      }}
    rescue
      e ->
        Logger.error("Failed to extract payment data: #{inspect(e)}")
        {:error, "Invalid payment data"}
    end
  end

  defp validate_till_number(%{till_number: till}) do
    if till == @till_number do
      :ok
    else
      {:error, "Invalid till number"}
    end
  end

  defp find_tenant(%{phone_number: phone, bill_ref_number: door_number}) do
    case Store.get_user_by_phone(phone) do
      %{door_number: ^door_number} = tenant ->
        {:ok, tenant}
      nil ->
        case Store.get_user_by_door_number(door_number) do
          nil -> {:error, "No tenant found"}
          tenant -> {:ok, tenant}
        end
      _tenant ->
        {:error, "Phone number and door number mismatch"}
    end
  end

  defp create_payment(payment_data, tenant) do
    payment_attrs = Map.merge(payment_data, %{
      tenant_id: tenant.id,
      status: "completed"
    })

    case Payments.create_payment(payment_attrs) do
      {:ok, payment} = result ->
        broadcast_payment(payment)
        result
      {:error, _changeset} = error -> error
    end
  end

  defp broadcast_payment(payment) do
    KejaDigitalWeb.Endpoint.broadcast!(
      "tenant:#{payment.tenant_id}",
      "payment_updated",
      %{payment: payment}
    )
  end

  defp clean_phone_number(phone) do
    phone
    |> String.replace(~r/[^0-9]/, "")
    |> case do
      "254" <> _ = phone -> phone
      "0" <> rest -> "254" <> rest
      "+254" <> rest -> "254" <> rest
      phone -> phone
    end
  end

  defp parse_transaction_date(_date_string) do
    DateTime.utc_now()
  end
end
