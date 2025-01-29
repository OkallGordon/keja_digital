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
    |> validate_properties_count()
  end

  defp validate_properties_count(changeset) do
    case {get_field(changeset, :total_properties), get_field(changeset, :occupied_properties)} do
      {total, occupied} when not is_nil(total) and not is_nil(occupied) and occupied > total ->
        add_error(changeset, :occupied_properties, "cannot exceed total properties")
      _ ->
        changeset
    end
  end
end
