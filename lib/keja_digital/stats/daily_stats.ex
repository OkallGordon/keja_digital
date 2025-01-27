defmodule KejaDigital.Stats.DailyStat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "daily_stats" do
    field :date, :date
    field :new_users, :integer
    field :new_properties, :integer
    field :daily_revenue, :decimal
    field :active_listings, :integer

    timestamps()
  end

  def changeset(daily_stat, attrs) do
    daily_stat
    |> cast(attrs, [:date, :new_users, :new_properties, :daily_revenue, :active_listings])
    |> validate_required([:date, :new_users, :new_properties, :daily_revenue, :active_listings])
    |> validate_number(:new_users, greater_than_or_equal_to: 0)
    |> validate_number(:new_properties, greater_than_or_equal_to: 0)
    |> validate_number(:active_listings, greater_than_or_equal_to: 0)
    |> unique_constraint(:date)
  end
end
