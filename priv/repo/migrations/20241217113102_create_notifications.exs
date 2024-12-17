defmodule KejaDigital.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :title, :string
      add :content, :text
      add :is_read, :boolean, default: false, null: false
      add :user_id, references(:users, on_delete: :nothing)
      add :tenant_agreement_id, references(:tenant_agreements, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:notifications, [:user_id])
    create index(:notifications, [:tenant_agreement_id])
  end
end
