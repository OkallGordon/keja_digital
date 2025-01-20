defmodule KejaDigital.Repo.Migrations.CreateProperties do
  use Ecto.Migration

  def change do
    create table(:properties) do
      add :title, :string, null: false
      add :description, :text
      add :price, :decimal, null: false
      add :status, :string, null: false, default: "active"
      add :property_type, :string, null: false
      add :bedrooms, :integer
      add :bathrooms, :integer
      add :floor_area, :integer
      add :location, :string, null: false
      add :saved, :boolean, default: false
      add :featured, :boolean, default: false
      add :owner_id, :integer, null: false

      timestamps()
    end

    create index(:properties, [:status])
    create index(:properties, [:owner_id])
    create index(:properties, [:property_type])
  end
end
