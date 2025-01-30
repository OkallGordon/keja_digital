defmodule KejaDigital.Repo.Migrations.AddUserIdToDoorNumbers do
  use Ecto.Migration

  def change do
    alter table(:door_numbers) do
      add :user_id, references(:users, on_delete: :nilify_all)
    end

    create index(:door_numbers, [:user_id])
  end
end
