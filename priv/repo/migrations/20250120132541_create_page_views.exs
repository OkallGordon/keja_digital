defmodule KejaDigital.Repo.Migrations.CreatePageViews do
  use Ecto.Migration

  def change do
    create table(:page_views) do
      add :path, :string, null: false
      add :view_count, :integer, null: false, default: 0
      add :viewed_on, :date, null: false
      add :ip_address, :string
      add :user_agent, :string
      add :referrer, :string

      timestamps(type: :utc_datetime)
    end

    create index(:page_views, [:path, :viewed_on])
  end
end
