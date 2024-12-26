defmodule KejaDigital.Repo.Migrations.ChangeDoorNumberToString do
  use Ecto.Migration

  def change do
    alter table(:payments) do
      remove :door_number
      add :door_number, :string, null: false
    end
  end
end
