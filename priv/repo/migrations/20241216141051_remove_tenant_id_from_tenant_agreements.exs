defmodule KejaDigital.Repo.Migrations.RemoveTenantIdFromTenantAgreements do
  use Ecto.Migration

  def change do
    alter table(:tenant_agreements) do
      remove :tenant_id
    end
  end
end
