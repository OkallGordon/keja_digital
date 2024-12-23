defmodule KejaDigitalWeb.MpesaCallbackController do
  use KejaDigitalWeb, :controller

  alias KejaDigital.Payments

  def confirmation(conn, %{"Body" => %{"stkCallback" => %{"CallbackMetadata" => metadata}}}) do
    transaction_id = get_metadata_value(metadata, "MpesaReceiptNumber")
    amount = get_metadata_value(metadata, "Amount")
    phone_number = get_metadata_value(metadata, "PhoneNumber")
    paid_at = get_metadata_value(metadata, "TransactionDate")

    # Save payment record
    case Payments.create_mpesa_payment(%{
           transaction_id: transaction_id,
           amount: Decimal.new(amount),
           phone_number: phone_number,
           till_number: "4154742",
           status: "completed",
           paid_at: parse_datetime(paid_at)
         }) do
      {:ok, _payment} ->
        send_resp(conn, 200, "Payment received.")

      {:error, _changeset} ->
        send_resp(conn, 400, "Failed to record payment.")
    end
  end

  defp get_metadata_value(metadata, key) do
    Enum.find_value(metadata, fn %{"Name" => name, "Value" => value} ->
      if name == key, do: value
    end)
  end

  defp parse_datetime(datetime_string) do
    DateTime.from_iso8601(datetime_string)
    |> case do
      {:ok, dt, _} -> dt
      _ -> DateTime.utc_now()
    end
  end
end
