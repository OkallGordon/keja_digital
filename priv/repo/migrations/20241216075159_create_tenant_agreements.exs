defmodule KejaDigital.Repo.Migrations.CreateTenantAgreements do
  use Ecto.Migration

  def change do
    create table(:tenant_agreements) do
        add :tenant_id, references(:users, on_delete: :delete_all), null: false
        add :tenant_address, :string
        add :tenant_phone, :string
        add :rent, :decimal
        add :late_fee, :string
        add :deposit, :decimal
        add :signature, :string
        add :start_date, :date
        add :agreement_content, :string
        add :signed_at, :naive_datetime

        timestamps(type: :utc_datetime)

      end

      create unique_index(:tenant_agreements, [:tenant_id])
    end
  end
