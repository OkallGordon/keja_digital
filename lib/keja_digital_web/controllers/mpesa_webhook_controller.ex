defmodule KejaDigitalWeb.MpesaWebhookController do
  use KejaDigitalWeb, :controller
  alias KejaDigital.Payments
  alias KejaDigital.Store
  require Logger

  def handle_callback(conn, params) do
    Logger.info("Received Mpesa callback: #{inspect(params)}")

    with {:ok, payment_params} <- extract_payment_params(params),
         {:ok, tenant} <- find_tenant(payment_params),
         {:ok, payment} <- create_payment(payment_params, tenant) do

      # Broadcast the payment update
      broadcast_payment_update(payment)

      conn
      |> put_status(:ok)
      |> json(%{status: "success", message: "Payment processed successfully"})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.error("Payment validation failed: #{inspect(changeset)}")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: format_errors(changeset)})

      {:error, reason} ->
        Logger.error("Payment processing failed: #{reason}")

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: reason})
    end
  end

  defp extract_payment_params(params) do
    try do
      {:ok, %{
        transaction_id: params["TransID"],
        phone_number: clean_phone_number(params["MSISDN"]),
        amount: Decimal.new(params["TransAmount"]),
        till_number: "4154742",
        bill_ref_number: params["BillRefNumber"], # This should be the door number
        payment_date: parse_transaction_date(params["TransTime"])
      }}
    rescue
      e ->
        Logger.error("Failed to extract payment params: #{inspect(e)}")
        {:error, "Invalid payment data format"}
    end
  end

  defp find_tenant(%{phone_number: phone, bill_ref_number: door_number}) do
    case Store.get_user_by_phone(phone) do
      %{door_number: ^door_number} = tenant ->
        {:ok, tenant}
      nil ->
        case Store.get_user_by_door_number(door_number) do
          nil -> {:error, "No tenant found matching the payment details"}
          tenant -> {:ok, tenant}
        end
      _tenant ->
        {:error, "Phone number and door number mismatch"}
    end
  end

  defp create_payment(payment_params, tenant) do
    payment_params
    |> Map.put(:tenant_id, tenant.id)
    |> Map.put(:status, "completed")
    |> Payments.create_payment()
  end

  defp broadcast_payment_update(payment) do
    KejaDigitalWeb.Endpoint.broadcast!(
      "tenant:#{payment.tenant_id}",
      "payment_updated",
      %{
        payment: %{
          id: payment.id,
          amount: payment.amount,
          transaction_id: payment.transaction_id,
          status: payment.status,
          inserted_at: payment.inserted_at
        }
      }
    )
  end

  defp clean_phone_number(phone) when is_binary(phone) do
    phone
    |> String.replace(~r/[^0-9]/, "")
    |> case do
      "254" <> _ = phone -> phone
      "0" <> rest -> "254" <> rest
      "+254" <> rest -> "254" <> rest
      phone -> phone
    end
  end
  defp clean_phone_number(phone), do: phone

  defp parse_transaction_date(time) when is_binary(time) do
    case NaiveDateTime.from_iso8601(time) do
      {:ok, datetime} -> datetime
      _ -> NaiveDateTime.utc_now()
    end
  end
  defp parse_transaction_date(_), do: NaiveDateTime.utc_now()

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
