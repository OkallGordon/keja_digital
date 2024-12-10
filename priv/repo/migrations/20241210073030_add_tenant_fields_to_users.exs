defmodule KejaDigital.Repo.Migrations.AddTenantFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :full_name, :string
      add :postal_address, :string
      add :phone_number, :string
      add :nationality, :string
      add :organization, :string
      add :next_of_kin, :string
      add :next_of_kin_contact, :string
      add :photo, :string
      add :passport, :string
      add :door_number, :string
    end
  end
end
