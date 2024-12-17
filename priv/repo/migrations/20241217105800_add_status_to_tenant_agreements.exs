defmodule KejaDigital.Repo.Migrations.AddStatusToTenantAgreements do
  use Ecto.Migration

  def change do
    alter table(:tenant_agreements) do
      add :status, :string, default: "pending_review"
  end
end
end
