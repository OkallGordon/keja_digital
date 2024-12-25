defmodule KejaDigital.Repo.Migrations.AddUnitIdToPayments do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      add :unit_id, :integer
    end
  end
end
