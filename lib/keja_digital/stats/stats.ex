defmodule KejaDigital.Stats.Stat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stats" do
    field :total_users, :integer
    field :active_users, :integer
    field :total_properties, :integer
    field :occupied_properties, :integer
    field :total_revenue, :decimal
    field :monthly_revenue, :decimal
    field :timestamp, :utc_datetime

    timestamps()
  end

  def changeset(stat, attrs) do
    stat
    |> cast(attrs, [:total_users, :active_users, :total_properties, :occupied_properties, :total_revenue, :monthly_revenue, :timestamp])
    |> validate_required([:total_users, :active_users, :total_properties, :occupied_properties, :total_revenue, :monthly_revenue, :timestamp])
    |> validate_number(:total_users, greater_than_or_equal_to: 0)
    |> validate_number(:active_users, greater_than_or_equal_to: 0)
    |> validate_number(:total_properties, greater_than_or_equal_to: 0)
    |> validate_number(:occupied_properties, greater_than_or_equal_to: 0)
  end
end
