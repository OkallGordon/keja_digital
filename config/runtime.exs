import Config

if config_env() in [:dev, :test, :prod] do
  if Code.ensure_loaded?(Dotenv) do
    Dotenv.load()
  end
end

# If PHX_SERVER env var is set, configure the server to start automatically
if System.get_env("PHX_SERVER") do
  config :keja_digital, KejaDigitalWeb.Endpoint, server: true
end

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :keja_digital, KejaDigital.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  # Use Render-specific hostname if available, fall back to PHX_HOST or default
  host = System.get_env("RENDER_EXTERNAL_HOSTNAME") || System.get_env("PHX_HOST") || "example.com"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :keja_digital, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :keja_digital, KejaDigitalWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base,
    server: true,  # Ensure the server starts automatically
    check_origin: false  # For Render deployments, this helps with WebSocket connections

  # Mailer configuration (if needed)
  # config :keja_digital, KejaDigital.Mailer,
  #   adapter: Swoosh.Adapters.Sendgrid,
  #   api_key: System.get_env("SENDGRID_API_KEY")

  # If you're using Swoosh, configure the API client
  # config :swoosh, :api_client, Swoosh.ApiClient.Finch
end
