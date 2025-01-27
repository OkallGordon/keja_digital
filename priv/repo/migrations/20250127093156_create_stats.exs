defmodule KejaDigital.Repo.Migrations.CreateStats do
  use Ecto.Migration

  def change do
    create table(:stats) do
      add :total_users, :integer, null: false
      add :active_users, :integer, null: false
      add :total_properties, :integer, null: false
      add :occupied_properties, :integer, null: false
      add :total_revenue, :decimal, precision: 10, scale: 2, null: false
      add :monthly_revenue, :decimal, precision: 10, scale: 2, null: false
      add :timestamp, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
