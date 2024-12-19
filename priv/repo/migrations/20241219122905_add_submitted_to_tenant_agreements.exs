defmodule KejaDigital.Repo.Migrations.AddSubmittedToTenantAgreements do
  use Ecto.Migration

  def change do
    alter table(:tenant_agreements) do
      add :submitted, :boolean, default: false
    end
  end
end
