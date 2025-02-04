defmodule KejaDigital.Repo.Migrations.AddResetPasswordTokenToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :reset_password_token, :string
    end

    create index(:users, [:reset_password_token])
  end
end
