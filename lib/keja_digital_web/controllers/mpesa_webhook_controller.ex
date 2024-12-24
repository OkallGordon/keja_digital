defmodule KejaDigitalWeb.MpesaWebhookController do
  use KejaDigitalWeb, :controller
  alias KejaDigital.Payments

  def handle_callback(conn, params) do
    with {:ok, payment_params} <- extract_payment_params(params),
         {:ok, _payment} <- Payments.create_payment(payment_params) do

      conn
      |> put_status(:ok)
      |> json(%{status: "success", message: "Payment processed successfully"})
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", errors: format_errors(changeset)})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{status: "error", message: reason})
    end
  end

  defp extract_payment_params(params) do
    {:ok, %{
      transaction_id: params["TransID"],
      phone_number: params["MSISDN"],
      amount: params["TransAmount"],
      till_number: "4154742",
      payment_date: NaiveDateTime.utc_now()
    }}
  end

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
