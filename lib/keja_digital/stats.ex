defmodule KejaDigital.Stats do
  @moduledoc """
  The Stats context.
  """

  import Ecto.Query, warn: false
  alias KejaDigital.Repo
  alias KejaDigital.Stats.{Stat, DailyStat, PerformanceMetric}

  @doc """
  Creates a stat.
  """
  def create_stats(attrs \\ %{}) do
    %Stat{}
    |> Stat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a daily stat.
  """
  def create_daily_stats(attrs \\ %{}) do
    %DailyStat{}
    |> DailyStat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a performance metric.
  """
  def create_performance_metric(attrs \\ %{}) do
    %PerformanceMetric{}
    |> PerformanceMetric.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single stat.
  """
  def get_stats!(id), do: Repo.get!(Stat, id)

  @doc """
  Gets a single daily stat.
  """
  def get_daily_stats!(id), do: Repo.get!(DailyStat, id)

  @doc """
  Gets a single performance metric.
  """
  def get_performance_metric!(id), do: Repo.get!(PerformanceMetric, id)

  @doc """
  Returns the list of stats.
  """
  def list_stats do
    Repo.all(Stat)
  end

  @doc """
  Returns the list of daily stats.
  """
  def list_daily_stats do
    Repo.all(DailyStat)
  end

  @doc """
  Returns the list of performance metrics.
  """
  def list_performance_metrics do
    Repo.all(PerformanceMetric)
  end
end
