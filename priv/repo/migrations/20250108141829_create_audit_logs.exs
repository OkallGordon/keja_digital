defmodule KejaDigital.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs) do
      add :action, :string, null: false
      add :actor_id, :integer
      add :actor_email, :string
      add :target_type, :string, null: false
      add :target_id, :integer, null: false
      add :changes, :map, default: %{}
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime)
    end
  end
end
