defmodule KejaDigital.MpesaPayment do
  def initiate_stk_push(phone_number, amount, _description) do
    # This is a mock implementation. In a real-world scenario,
    # you'd integrate with Daraja API or your payment gateway

    # Simulate payment processing
    case validate_and_simulate_payment(phone_number, amount) do
      {:ok, transaction_id} ->
        %{
          success: true,
          transaction_id: transaction_id,
          amount: amount,
          timestamp: NaiveDateTime.utc_now()
        }

      {:error, reason} ->
        %{
          success: false,
          error: reason
        }
    end
  end

  defp validate_and_simulate_payment(phone_number, amount) do
    # Simulate some basic validation and random success/failure
    cond do
      not Regex.match?(~r/^(07|01)\d{8}$/, phone_number) ->
        {:error, "Invalid phone number"}

      amount < 1 ->
        {:error, "Invalid amount"}

      # Simulate a 90% success rate
      :rand.uniform(10) <= 9 ->
        {:ok, generate_transaction_id()}

      true ->
        {:error, "Payment processing failed"}
    end
  end

  defp generate_transaction_id do
    # Generate a random transaction ID
    "MPX" <> (:rand.uniform(1000000) |> Integer.to_string())
  end
end
