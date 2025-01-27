defmodule KejaDigital.Repo.Migrations.CreateDailyStats do
  use Ecto.Migration

  def change do
    create table(:daily_stats) do
      add :date, :date, null: false
      add :new_users, :integer, null: false
      add :new_properties, :integer, null: false
      add :daily_revenue, :decimal, precision: 10, scale: 2, null: false
      add :active_listings, :integer, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:daily_stats, [:date])
    end
  end
