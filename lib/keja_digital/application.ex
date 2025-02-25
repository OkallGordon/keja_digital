defmodule KejaDigital.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  @impl true
  def start(_type, _args) do

    validate_mpesa_config()


    children = [
      KejaDigitalWeb.Telemetry,
      KejaDigital.Repo,
      {DNSCluster, query: Application.get_env(:keja_digital, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: KejaDigital.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: KejaDigital.Finch},
      # Start a worker by calling: KejaDigital.Worker.start_link(arg)
      # {KejaDigital.Worker, arg},
      # Start to serve requests, typically the last entry
      KejaDigitalWeb.Endpoint,
      KejaDigital.PaymentChecker,
      KejaDigital.Mpesa.Auth
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KejaDigital.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp validate_mpesa_config do
    required_keys = [:consumer_key, :consumer_secret, :business_short_code, :passkey]
    config = Application.get_env(:keja_digital, :mpesa)

    case validate_keys(config, required_keys) do
      :ok ->
        Logger.info("MPesa configuration validated successfully")
      {:error, missing} ->
        Logger.warning("Missing MPesa configuration keys: #{inspect(missing)}")
        if Application.get_env(:keja_digital, :env) == :prod do
          raise "Missing required MPesa configuration in production: #{inspect(missing)}"
        end
    end
  end

  defp validate_keys(config, required_keys) do
    missing = Enum.filter(required_keys, fn key ->
      is_nil(config[key]) || config[key] == ""
    end)

    if Enum.empty?(missing), do: :ok, else: {:error, missing}
  end


  @impl true
  def config_change(changed, _new, removed) do
    KejaDigitalWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
