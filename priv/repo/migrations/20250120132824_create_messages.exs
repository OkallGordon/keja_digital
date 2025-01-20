defmodule KejaDigital.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text, null: false
      add :subject, :string
      add :status, :string, null: false, default: "unread"
      add :sender_email, :string, null: false
      add :sender_name, :string, null: false
      add :recipient_id, :integer
      add :message_type, :string, null: false, default: "inquiry"
      add :read_at, :naive_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:status])
    create index(:messages, [:recipient_id])
  end
end
