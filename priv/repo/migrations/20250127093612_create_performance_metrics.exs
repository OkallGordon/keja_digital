defmodule KejaDigital.Repo.Migrations.CreatePerformanceMetrics do
  use Ecto.Migration

  def change do
    create table(:performance_metrics) do
      add :metric_type, :string, null: false
      add :value, :decimal, precision: 10, scale: 2, null: false
      add :period, :string, null: false
      add :timestamp, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:performance_metrics, [:metric_type, :period])
  end
end
