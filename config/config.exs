import Config

config :keja_digital,
  ecto_repos: [KejaDigital.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :keja_digital, KejaDigitalWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: KejaDigitalWeb.ErrorHTML, json: KejaDigitalWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: KejaDigital.PubSub,
  live_view: [signing_salt: "NaN881MN"]

# Configures the mailer
config :keja_digital, KejaDigital.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild
config :esbuild,
  version: "0.17.11",
  keja_digital: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind
config :tailwind,
  version: "3.4.3",
  keja_digital: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# MPesa Configuration - Development defaults
config :keja_digital, :mpesa,
  consumer_key: System.get_env("MPESA_CONSUMER_KEY", "hoi93y89r893u1ihf9fhqhhqyfyfqfjf"),
  consumer_secret: System.get_env("MPESA_CONSUMER_SECRET", "dbnwnbwhhwh36i322gdwbjkdjwwjkwd"),
  passkey: System.get_env("MPESA_PASSKEY"),
  business_short_code: System.get_env("MPESA_BUSINESS_SHORT_CODE"),
  callback_url: System.get_env("MPESA_CALLBACK_URL"),
  base_url: "https://sandbox.safaricom.co.ke"

# Import environment specific config
import_config "#{config_env()}.exs"
