defmodule KejaDigital.StatsTest do
  use KejaDigital.DataCase

  alias KejaDigital.Stats

  describe "stats" do
    alias KejaDigital.Stats.Stat

    import KejaDigital.StatsFixtures

    @invalid_attrs %{messages: nil, total_views: nil, active_listings: nil, saved_properties: nil}

    test "list_stats/0 returns all stats" do
      stat = stat_fixture()
      assert Stats.list_stats() == [stat]
    end

    test "get_stat!/1 returns the stat with given id" do
      stat = stat_fixture()
      assert Stats.get_stat!(stat.id) == stat
    end

    test "create_stat/1 with valid data creates a stat" do
      valid_attrs = %{messages: 42, total_views: 42, active_listings: 42, saved_properties: 42}

      assert {:ok, %Stat{} = stat} = Stats.create_stat(valid_attrs)
      assert stat.messages == 42
      assert stat.total_views == 42
      assert stat.active_listings == 42
      assert stat.saved_properties == 42
    end

    test "create_stat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_stat(@invalid_attrs)
    end

    test "update_stat/2 with valid data updates the stat" do
      stat = stat_fixture()
      update_attrs = %{messages: 43, total_views: 43, active_listings: 43, saved_properties: 43}

      assert {:ok, %Stat{} = stat} = Stats.update_stat(stat, update_attrs)
      assert stat.messages == 43
      assert stat.total_views == 43
      assert stat.active_listings == 43
      assert stat.saved_properties == 43
    end

    test "update_stat/2 with invalid data returns error changeset" do
      stat = stat_fixture()
      assert {:error, %Ecto.Changeset{}} = Stats.update_stat(stat, @invalid_attrs)
      assert stat == Stats.get_stat!(stat.id)
    end

    test "delete_stat/1 deletes the stat" do
      stat = stat_fixture()
      assert {:ok, %Stat{}} = Stats.delete_stat(stat)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_stat!(stat.id) end
    end

    test "change_stat/1 returns a stat changeset" do
      stat = stat_fixture()
      assert %Ecto.Changeset{} = Stats.change_stat(stat)
    end
  end
end
