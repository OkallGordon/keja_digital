defmodule KejaDigital.StatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `KejaDigital.Stats` context.
  """

  @doc """
  Generate a statistics entry.
  """
  def stat_fixture(attrs \\ %{}) do
    {:ok, stats} =
      attrs
      |> Enum.into(%{
        total_users: 42,
        active_users: 35,
        total_properties: 100,
        occupied_properties: 80,
        total_revenue: Decimal.new("50000.00"),
        monthly_revenue: Decimal.new("5000.00"),
        timestamp: DateTime.utc_now()
      })
      |> KejaDigital.Stats.create_stats()

    stats
  end

  @doc """
  Generate a daily stats entry.
  """
  def daily_stat_fixture(attrs \\ %{}) do
    {:ok, daily_stats} =
      attrs
      |> Enum.into(%{
        date: Date.utc_today(),
        new_users: 5,
        new_properties: 3,
        daily_revenue: Decimal.new("1000.00"),
        active_listings: 20
      })
      |> KejaDigital.Stats.create_daily_stats()

    daily_stats
  end

  @doc """
  Generate a performance metric entry.
  """
  def performance_metric_fixture(attrs \\ %{}) do
    {:ok, metric} =
      attrs
      |> Enum.into(%{
        metric_type: "occupancy_rate",
        value: Decimal.new("80.5"),
        period: "monthly",
        timestamp: DateTime.utc_now()
      })
      |> KejaDigital.Stats.create_performance_metric()

    metric
  end
end
