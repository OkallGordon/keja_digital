defmodule KejaDigital.Stats.PerformanceMetric do
  use Ecto.Schema
  import Ecto.Changeset

  schema "performance_metrics" do
    field :metric_type, :string
    field :value, :decimal
    field :period, :string
    field :timestamp, :utc_datetime

    timestamps()
  end

  def changeset(performance_metric, attrs) do
    performance_metric
    |> cast(attrs, [:metric_type, :value, :period, :timestamp])
    |> validate_required([:metric_type, :value, :period, :timestamp])
    |> validate_inclusion(:period, ["daily", "weekly", "monthly", "yearly"])
    |> validate_inclusion(:metric_type, ["occupancy_rate", "revenue_growth", "user_growth", "property_growth"])
  end
end
