defmodule KejaDigital.Repo.Migrations.AddViewerFieldsToPageViews do
  use Ecto.Migration

  def change do
    alter table(:page_views) do
      add :viewer_id, references(:users)
      add :viewer_type, :string
    end

    create index(:page_views, [:viewer_id])
  end
end
