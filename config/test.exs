import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :keja_digital, KejaDigital.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "keja_digital_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :keja_digital, KejaDigitalWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "XkmTnpmU//Be62zPcJwPf24LmXO7HhHNrquL0Gm+3XVu+H/Rf6zoKZqACgd6Xwke",
  server: false

# In test we don't send emails
config :keja_digital, KejaDigital.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Add this at the end of your dev.exs file
config :keja_digital, :mpesa,
  consumer_key: System.get_env("MPESA_CONSUMER_KEY"),
  consumer_secret: System.get_env("MPESA_CONSUMER_SECRET"),
  business_short_code: System.get_env("MPESA_BUSINESS_SHORT_CODE"),
  passkey: System.get_env("MPESA_PASSKEY")
