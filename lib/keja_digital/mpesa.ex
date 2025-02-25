defmodule KejaDigital.Mpesa do
  @moduledoc """
  Handles M-Pesa API integration for rent payments.
  Includes STK Push and transaction status checks.
  """

  require Logger

  @type stk_push_params :: %{
    amount: integer(),
    phone_number: String.t(),
    account_reference: String.t(),
    transaction_desc: String.t()
  }

  @doc """
  Initiates an STK push request to the customer's phone
  """
  @spec initiate_stk_push(stk_push_params()) ::
    {:ok, map()} | {:error, term()}
  def initiate_stk_push(params) do
    with {:ok, token} <- fetch_oauth_token(),
         {:ok, timestamp} <- get_timestamp(),
         {:ok, password} <- generate_password(timestamp) do

      make_stk_push_request(token, timestamp, password, params)
    end
  end

  defp make_stk_push_request(token, timestamp, password, params) do
    url = "#{get_base_url()}/mpesa/stkpush/v1/processrequest"

    headers = [
      {"Authorization", "Bearer #{token}"},
      {"Content-Type", "application/json"}
    ]

    body = Jason.encode!(%{
      BusinessShortCode: get_config(:business_short_code),
      Password: password,
      Timestamp: timestamp,
      TransactionType: "CustomerPayBillOnline",
      Amount: params.amount,
      PartyA: format_phone_number(params.phone_number),
      PartyB: get_config(:business_short_code),
      PhoneNumber: format_phone_number(params.phone_number),
      CallBackURL: get_config(:callback_url),
      AccountReference: params.account_reference,
      TransactionDesc: params.transaction_desc
    })

    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, response} -> {:ok, response}
          error -> handle_json_error(error)
        end

      {:ok, %{status_code: status, body: response_body}} ->
        Logger.error("STK Push failed with status #{status}: #{inspect(response_body)}")
        {:error, :stk_push_failed}

      {:error, reason} ->
        Logger.error("STK Push request failed: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Checks the status of an STK push transaction
  """
  @spec check_transaction_status(String.t()) ::
    {:ok, map()} | {:error, term()}
  def check_transaction_status(checkout_request_id) do
    with {:ok, token} <- fetch_oauth_token(),
         {:ok, timestamp} <- get_timestamp(),
         {:ok, password} <- generate_password(timestamp) do

      url = "#{get_base_url()}/mpesa/stkpushquery/v1/query"

      headers = [
        {"Authorization", "Bearer #{token}"},
        {"Content-Type", "application/json"}
      ]

      body = Jason.encode!(%{
        BusinessShortCode: get_config(:business_short_code),
        Password: password,
        Timestamp: timestamp,
        CheckoutRequestID: checkout_request_id
      })

      case HTTPoison.post(url, body, headers) do
        {:ok, %{status_code: 200, body: response_body}} ->
          Jason.decode(response_body)

        {:ok, %{status_code: status, body: response_body}} ->
          Logger.error("Transaction status check failed with status #{status}: #{inspect(response_body)}")
          {:error, :status_check_failed}

        {:error, reason} ->
          Logger.error("Transaction status request failed: #{inspect(reason)}")
          {:error, reason}
      end
    end
  end

  # Helper functions
  defp fetch_oauth_token do
    case KejaDigital.Mpesa.Auth.get_token() do
      {:ok, token} -> {:ok, token}
      error ->
        Logger.error("Failed to fetch OAuth token: #{inspect(error)}")
        {:error, :auth_failed}
    end
  end

  defp get_timestamp do
    {:ok, DateTime.utc_now() |> DateTime.to_string() |> String.slice(0, 14)}
  end

  defp generate_password(timestamp) do
    shortcode = get_config(:business_short_code)
    passkey = get_config(:passkey)

    case {shortcode, passkey} do
      {nil, _} -> {:error, :missing_shortcode}
      {_, nil} -> {:error, :missing_passkey}
      {shortcode, passkey} ->
        password = "#{shortcode}#{passkey}#{timestamp}"
        |> Base.encode64()
        {:ok, password}
    end
  end

  defp format_phone_number("0" <> rest) do
    "254" <> rest
  end
  defp format_phone_number("254" <> _ = phone_number), do: phone_number
  defp format_phone_number("+254" <> rest), do: "254" <> rest
  defp format_phone_number(phone_number), do: phone_number

  defp get_base_url, do: get_config(:base_url)

  defp get_config(key) do
    Application.get_env(:keja_digital, :mpesa)[key]
  end

  defp handle_json_error({:error, reason}) do
    Logger.error("JSON decode error: #{inspect(reason)}")
    {:error, :invalid_response}
  end
end
