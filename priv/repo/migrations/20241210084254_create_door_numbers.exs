defmodule KejaDigital.Repo.Migrations.CreateDoorNumbers do
  use Ecto.Migration

  def change do
    create table(:door_numbers) do
      add :number, :string, null: false
      add :occupied, :boolean, default: false, null: false

      timestamps()
    end

    create unique_index(:door_numbers, [:number])
  end
end
