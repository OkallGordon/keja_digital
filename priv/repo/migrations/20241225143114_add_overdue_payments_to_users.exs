defmodule KejaDigital.Repo.Migrations.AddOverduePaymentsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :overdue_payments, :integer, virtual: true
      end
    end
  end
