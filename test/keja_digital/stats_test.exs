defmodule KejaDigital.StatsTest do
  use KejaDigital.DataCase

  alias KejaDigital.Stats.{DailyStat, PerformanceMetric, Stat}

  describe "daily_stats" do
    @valid_attrs %{
      date: ~D[2024-01-01],
      new_users: 10,
      new_properties: 5,
      daily_revenue: Decimal.new("1000.00"),
      active_listings: 100
    }
    @invalid_attrs %{
      date: nil,
      new_users: nil,
      new_properties: nil,
      daily_revenue: nil,
      active_listings: nil
    }
    @negative_attrs %{
      date: ~D[2024-01-01],
      new_users: -1,
      new_properties: -2,
      daily_revenue: Decimal.new("1000.00"),
      active_listings: -3
    }

    test "changeset with valid attributes" do
      changeset = DailyStat.changeset(%DailyStat{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = DailyStat.changeset(%DailyStat{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "changeset with negative values" do
      changeset = DailyStat.changeset(%DailyStat{}, @negative_attrs)
      refute changeset.valid?
      assert "must be greater than or equal to 0" in errors_on(changeset).new_users
      assert "must be greater than or equal to 0" in errors_on(changeset).new_properties
      assert "must be greater than or equal to 0" in errors_on(changeset).active_listings
    end

    test "changeset enforces unique date constraint" do
      {:ok, _stat} = %DailyStat{}
        |> DailyStat.changeset(@valid_attrs)
        |> Repo.insert()

      {:error, changeset} = %DailyStat{}
        |> DailyStat.changeset(@valid_attrs)
        |> Repo.insert()

      assert %{date: ["has already been taken"]} = errors_on(changeset)
    end
  end

  describe "performance_metrics" do
    @valid_attrs %{
      metric_type: "occupancy_rate",
      value: Decimal.new("85.5"),
      period: "monthly",
      timestamp: DateTime.utc_now()
    }
    @invalid_attrs %{
      metric_type: nil,
      value: nil,
      period: nil,
      timestamp: nil
    }
    @invalid_period_attrs %{
      metric_type: "occupancy_rate",
      value: Decimal.new("85.5"),
      period: "invalid_period",
      timestamp: DateTime.utc_now()
    }
    @invalid_metric_type_attrs %{
      metric_type: "invalid_metric",
      value: Decimal.new("85.5"),
      period: "monthly",
      timestamp: DateTime.utc_now()
    }

    test "changeset with valid attributes" do
      changeset = PerformanceMetric.changeset(%PerformanceMetric{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = PerformanceMetric.changeset(%PerformanceMetric{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "changeset with invalid period" do
      changeset = PerformanceMetric.changeset(%PerformanceMetric{}, @invalid_period_attrs)
      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).period
    end

    test "changeset with invalid metric type" do
      changeset = PerformanceMetric.changeset(%PerformanceMetric{}, @invalid_metric_type_attrs)
      refute changeset.valid?
      assert "is invalid" in errors_on(changeset).metric_type
    end

    test "validates all allowed periods" do
      for period <- ["daily", "weekly", "monthly", "yearly"] do
        attrs = Map.put(@valid_attrs, :period, period)
        changeset = PerformanceMetric.changeset(%PerformanceMetric{}, attrs)
        assert changeset.valid?
      end
    end

    test "validates all allowed metric types" do
      for metric_type <- ["occupancy_rate", "revenue_growth", "user_growth", "property_growth"] do
        attrs = Map.put(@valid_attrs, :metric_type, metric_type)
        changeset = PerformanceMetric.changeset(%PerformanceMetric{}, attrs)
        assert changeset.valid?
      end
    end
  end

  describe "stats" do
    @valid_attrs %{
      total_users: 1000,
      active_users: 750,
      total_properties: 500,
      occupied_properties: 450,
      total_revenue: Decimal.new("100000.00"),
      monthly_revenue: Decimal.new("10000.00"),
      timestamp: DateTime.utc_now()
    }
    @invalid_attrs %{
      total_users: nil,
      active_users: nil,
      total_properties: nil,
      occupied_properties: nil,
      total_revenue: nil,
      monthly_revenue: nil,
      timestamp: nil
    }
    @negative_attrs %{
      total_users: -1,
      active_users: -2,
      total_properties: -3,
      occupied_properties: -4,
      total_revenue: Decimal.new("100000.00"),
      monthly_revenue: Decimal.new("10000.00"),
      timestamp: DateTime.utc_now()
    }

    test "changeset with valid attributes" do
      changeset = Stat.changeset(%Stat{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = Stat.changeset(%Stat{}, @invalid_attrs)
      refute changeset.valid?
    end

    test "changeset with negative values" do
      changeset = Stat.changeset(%Stat{}, @negative_attrs)
      refute changeset.valid?
      assert "must be greater than or equal to 0" in errors_on(changeset).total_users
      assert "must be greater than or equal to 0" in errors_on(changeset).active_users
      assert "must be greater than or equal to 0" in errors_on(changeset).total_properties
      assert "must be greater than or equal to 0" in errors_on(changeset).occupied_properties
    end

    test "validates occupied_properties cannot exceed total_properties" do
      attrs = Map.merge(@valid_attrs, %{
        total_properties: 100,
        occupied_properties: 150
      })

      changeset = Stat.changeset(%Stat{}, attrs)
      # Note: You'll need to add this validation to your schema if you want this test to pass
      assert %{occupied_properties: ["cannot exceed total properties"]} = errors_on(changeset)
    end
  end
end
