defmodule KejaDigital.Mpesa do
  @moduledoc """
  Handles M-Pesa API integration for rent payments.
  """

  @consumer_key Application.compile_env(:keja_digital, :mpesa_consumer_key, "")
  @consumer_secret Application.compile_env(:keja_digital, :mpesa_consumer_secret, "")

  @base_url "https://sandbox.safaricom.co.ke"

  alias HTTPoison

  # Fetch OAuth token
  def fetch_oauth_token do
    url = "#{@base_url}/oauth/v1/generate?grant_type=client_credentials"
    auth = Base.encode64("#{@consumer_key}:#{@consumer_secret}")
    headers = [{"Authorization", "Basic #{auth}"}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, Jason.decode!(body)["access_token"]}

      {:ok, %HTTPoison.Response{status_code: status, body: body}} ->
        {:error, %{status: status, error: body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end
end
