defmodule KejaDigital.Repo.Migrations.AddRoleToAdmins do
  use Ecto.Migration

  def change do
   alter table(:admins) do
     add :role, :string, default: "admin"
   end
  end
end
