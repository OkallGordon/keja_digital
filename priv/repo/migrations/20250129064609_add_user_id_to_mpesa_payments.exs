defmodule KejaDigital.Repo.Migrations.AddUserIdToMpesaPayments do
  use Ecto.Migration

  def change do
    alter table(:mpesa_payments) do
      add :user_id, references(:users)
    end
  end
end
