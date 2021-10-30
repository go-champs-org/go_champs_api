defmodule GoChampsApi.FixedPlayerStatsTablesTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.FixedPlayerStatsTables
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Tournaments

  describe "fixed_player_stats_table" do
    alias GoChampsApi.FixedPlayerStatsTables.FixedPlayerStatsTable

    @valid_attrs %{player_stats: %{}}
    @update_attrs %{player_stats: %{}}
    @invalid_attrs %{player_stats: nil}

    def fixed_player_stats_table_fixture(attrs \\ %{}) do
      {:ok, fixed_player_stats_table} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TournamentHelpers.map_tournament_id_and_stat_id()
        |> FixedPlayerStatsTables.create_fixed_player_stats_table()

      fixed_player_stats_table
    end

    test "list_fixed_player_stats_table/0 returns all fixed_player_stats_table" do
      fixed_player_stats_table = fixed_player_stats_table_fixture()
      assert FixedPlayerStatsTables.list_fixed_player_stats_table() == [fixed_player_stats_table]
    end

    test "get_fixed_player_stats_table!/1 returns the fixed_player_stats_table with given id" do
      fixed_player_stats_table = fixed_player_stats_table_fixture()

      assert FixedPlayerStatsTables.get_fixed_player_stats_table!(fixed_player_stats_table.id) ==
               fixed_player_stats_table
    end

    test "get_fixed_player_stats_table_organization!/1 returns the organization with a give player id" do
      fixed_player_stats_table = fixed_player_stats_table_fixture()

      organization =
        FixedPlayerStatsTables.get_fixed_player_stats_table_organization!(
          fixed_player_stats_table.id
        )

      tournament = Tournaments.get_tournament!(fixed_player_stats_table.tournament_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "create_fixed_player_stats_table/1 with valid data creates a fixed_player_stats_table" do
      attrs = TournamentHelpers.map_tournament_id_and_stat_id(@valid_attrs)

      assert {:ok, %FixedPlayerStatsTable{} = fixed_player_stats_table} =
               FixedPlayerStatsTables.create_fixed_player_stats_table(attrs)

      assert fixed_player_stats_table.player_stats == %{}
    end

    test "create_fixed_player_stats_table/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               FixedPlayerStatsTables.create_fixed_player_stats_table(@invalid_attrs)
    end

    test "update_fixed_player_stats_table/2 with valid data updates the fixed_player_stats_table" do
      fixed_player_stats_table = fixed_player_stats_table_fixture()

      assert {:ok, %FixedPlayerStatsTable{} = fixed_player_stats_table} =
               FixedPlayerStatsTables.update_fixed_player_stats_table(
                 fixed_player_stats_table,
                 @update_attrs
               )

      assert fixed_player_stats_table.player_stats == %{}
    end

    test "update_fixed_player_stats_table/2 with invalid data returns error changeset" do
      fixed_player_stats_table = fixed_player_stats_table_fixture()

      assert {:error, %Ecto.Changeset{}} =
               FixedPlayerStatsTables.update_fixed_player_stats_table(
                 fixed_player_stats_table,
                 @invalid_attrs
               )

      assert fixed_player_stats_table ==
               FixedPlayerStatsTables.get_fixed_player_stats_table!(fixed_player_stats_table.id)
    end

    test "delete_fixed_player_stats_table/1 deletes the fixed_player_stats_table" do
      fixed_player_stats_table = fixed_player_stats_table_fixture()

      assert {:ok, %FixedPlayerStatsTable{}} =
               FixedPlayerStatsTables.delete_fixed_player_stats_table(fixed_player_stats_table)

      assert_raise Ecto.NoResultsError, fn ->
        FixedPlayerStatsTables.get_fixed_player_stats_table!(fixed_player_stats_table.id)
      end
    end

    test "change_fixed_player_stats_table/1 returns a fixed_player_stats_table changeset" do
      fixed_player_stats_table = fixed_player_stats_table_fixture()

      assert %Ecto.Changeset{} =
               FixedPlayerStatsTables.change_fixed_player_stats_table(fixed_player_stats_table)
    end
  end
end
