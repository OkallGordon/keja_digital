defmodule KejaDigital.Mpesa.Auth do
  use GenServer
  require Logger

  @refresh_interval :timer.minutes(50)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_token do
    GenServer.call(__MODULE__, :get_token)
  end

  @impl true
  @spec init(any()) :: {:ok, %{expires_at: nil, token: nil}, {:continue, :fetch_token}}
  def init(_opts) do
    {:ok, %{token: nil, expires_at: nil}, {:continue, :fetch_token}}
  end

  @impl true
  def handle_continue(:fetch_token, state) do
    {:noreply, refresh_token(state)}
  end

  @impl true
  def handle_call(:get_token, _from, %{token: _token, expires_at: expires_at} = state) do
    state =
      if should_refresh?(expires_at) do
        refresh_token(state)
      else
        state
      end

    {:reply, {:ok, state.token}, state}
  end

  @impl true
  def handle_info(:refresh_token, state) do
    {:noreply, refresh_token(state)}
  end

  defp refresh_token(state) do
    case fetch_new_token() do
      {:ok, token} ->
        Process.send_after(self(), :refresh_token, @refresh_interval)
        %{token: token, expires_at: DateTime.utc_now() |> DateTime.add(3600, :second), failures: 0}

      {:error, _reason} ->
        failures = (state[:failures] || 0) + 1
        # Exponential backoff: 1min, 2min, 4min, 8min, etc. up to 30min max
        backoff = min(:timer.minutes(2 ** failures), :timer.minutes(30))
        Logger.error("Failed to fetch MPesa token (attempt #{failures}). Retrying in #{div(backoff, 60000)} minutes")
        Process.send_after(self(), :refresh_token, backoff)
        Map.put(state, :failures, failures)
    end
  end

  defp should_refresh?(nil), do: true
  defp should_refresh?(expires_at) do
    DateTime.diff(expires_at, DateTime.utc_now()) < 300  # Refresh if less than 5 minutes left
  end

  defp fetch_new_token do
    config = Application.get_env(:keja_digital, :mpesa)
    credentials = Base.encode64("#{config[:consumer_key]}:#{config[:consumer_secret]}")

    headers = [
      {"Authorization", "Basic #{credentials}"},
      {"Content-Type", "application/json"}
    ]

    url = config[:base_url] || "https://sandbox.safaricom.co.ke"
    endpoint = "#{url}/oauth/v1/generate?grant_type=client_credentials"

    # Add timeout options to HTTPoison request
    options = [recv_timeout: 15000, timeout: 15000]

    case HTTPoison.get(endpoint, headers, options) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"access_token" => token}} ->
            Logger.info("Successfully fetched MPesa token")
            {:ok, token}
          error ->
            Logger.error("Failed to decode MPesa token response: #{inspect(error)}")
            {:error, {:decode_error, error}}
        end

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        Logger.error("MPesa token request failed with status #{status_code}: #{body}")
        {:error, {:http_error, status_code, body}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("MPesa token request error: #{inspect(reason)}")
        {:error, {:http_error, reason}}
    end
  end
end
