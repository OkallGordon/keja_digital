defmodule DigitalKeja.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def change do
    create table(:payments) do
      add :amount, :decimal, null: false
      add :due_date, :date, null: false
      add :status, :string, default: "pending", null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :door_number, references(:door_numbers, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:payments, [:user_id])
    create index(:payments, [:door_number])
  end
end
