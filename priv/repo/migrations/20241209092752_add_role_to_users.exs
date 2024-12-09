defmodule KejaDigital.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def change do
   alter table(:users) do
    add :role, :string, default: "tenant"
   end
  end
end
