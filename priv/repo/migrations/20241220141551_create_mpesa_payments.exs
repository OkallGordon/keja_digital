defmodule KejaDigital.Repo.Migrations.CreateMpesaPayments do
  use Ecto.Migration

  def change do
    create table(:mpesa_payments) do
      add :transaction_id, :string
      add :amount, :decimal
      add :phone_number, :string
      add :till_number, :string
      add :status, :string
      add :paid_at, :utc_datetime
      add :tenant_id, :integer

      timestamps(type: :utc_datetime)
    end

    create unique_index(:mpesa_payments, [:transaction_id])
  end
end
