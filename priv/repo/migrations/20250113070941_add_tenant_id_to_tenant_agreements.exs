defmodule KejaDigital.Repo.Migrations.AddTenantIdToTenantAgreements do
  use Ecto.Migration

  def change do
   alter table( :tenant_agreements) do
     add :tenant_id, :integer
   end
  end
end
