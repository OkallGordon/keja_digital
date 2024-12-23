defmodule KejaDigitalWeb.MpesaWebhookController do
  use KejaDigitalWeb, :controller
  alias KejaDigital.Payments

  def handle_callback(conn, params) do
    with {:ok, payment_data} <- extract_payment_data(params),
         {:ok, payment} <- Payments.create_mpesa_payment(payment_data) do

      KejaDigitalWeb.Endpoint.broadcast("payments", "new_payment", payment)

      conn
      |> put_status(:ok)
      |> json(%{status: "success"})
    else
      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: reason})
    end
  end

  defp extract_payment_data(params) do
    # Transform Safaricom webhook data into our payment format
    # You'll need to adjust this based on actual webhook payload
    {:ok, %{
      transaction_id: params["TransID"],
      phone_number: params["MSISDN"],
      amount: params["TransAmount"],
      till_number: "4154742",
      status: "completed"
    }}
  end
end
