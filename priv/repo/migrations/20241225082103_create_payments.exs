defmodule DigitalKeja.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :decimal, null: false
      add :due_date, :date, null: false
      add :status, :string, default: "pending", null: false
      add :tenant_id, references(:tenants, on_delete: :delete_all), null: false
      add :door_number, references(:door_number, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:payments, [:tenant_id])
    create index(:payments, [:door_number])
  end
end
