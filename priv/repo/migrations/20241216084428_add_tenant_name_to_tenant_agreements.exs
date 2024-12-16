defmodule KejaDigital.Repo.Migrations.AddTenantNameToTenantAgreements do
  use Ecto.Migration

  def change do
    alter table(:tenant_agreements) do
      add :tenant_name, :string
    end
  end
end
