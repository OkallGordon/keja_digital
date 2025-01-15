defmodule KejaDigital.Repo.Migrations.AddAdminIdToNotifications do
  use Ecto.Migration

  def change do
    alter table(:notifications) do
      add :admin_id, :integer
    end
  end
end
