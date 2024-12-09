defmodule KejaDigital.Repo do
  use Ecto.Repo,
    otp_app: :keja_digital,
    adapter: Ecto.Adapters.Postgres
end
