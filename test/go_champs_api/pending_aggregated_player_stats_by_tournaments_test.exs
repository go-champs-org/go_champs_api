defmodule GoChampsApi.PendingAggregatedPlayerStatsByTournamentsTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Helpers.OrganizationHelpers
  alias GoChampsApi.Tournaments
  alias GoChampsApi.PlayerStatsLogs
  alias GoChampsApi.PendingAggregatedPlayerStatsByTournaments
  alias GoChampsApi.AggregatedPlayerStatsByTournaments
  alias GoChampsApi.Helpers.PlayerHelpers

  describe "pending_aggregated_player_stats_by_tournament" do
    alias GoChampsApi.Tournaments.Tournament

    alias GoChampsApi.PendingAggregatedPlayerStatsByTournaments.PendingAggregatedPlayerStatsByTournament

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{tournament_id: nil}
    @valid_tournament_attrs %{
      name: "some name",
      slug: "some-slug",
      player_stats: [
        %{
          title: "some stat"
        },
        %{
          title: "another stat"
        }
      ]
    }

    def pending_aggregated_player_stats_by_tournament_fixture(attrs \\ %{}) do
      {:ok, pending_aggregated_player_stats_by_tournament} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TournamentHelpers.map_tournament_id()
        |> PendingAggregatedPlayerStatsByTournaments.create_pending_aggregated_player_stats_by_tournament()

      pending_aggregated_player_stats_by_tournament
    end

    test "list_pending_aggregated_player_stats_by_tournament/0 returns all pending_aggregated_player_stats_by_tournament" do
      pending_aggregated_player_stats_by_tournament =
        pending_aggregated_player_stats_by_tournament_fixture()

      assert PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament() ==
               [pending_aggregated_player_stats_by_tournament]
    end

    test "get_pending_aggregated_player_stats_by_tournament!/1 returns the pending_aggregated_player_stats_by_tournament with given id" do
      pending_aggregated_player_stats_by_tournament =
        pending_aggregated_player_stats_by_tournament_fixture()

      assert PendingAggregatedPlayerStatsByTournaments.get_pending_aggregated_player_stats_by_tournament!(
               pending_aggregated_player_stats_by_tournament.id
             ) == pending_aggregated_player_stats_by_tournament
    end

    test "create_pending_aggregated_player_stats_by_tournament/1 with valid data creates a pending_aggregated_player_stats_by_tournament" do
      attrs =
        @valid_attrs
        |> TournamentHelpers.map_tournament_id()

      assert {:ok,
              %PendingAggregatedPlayerStatsByTournament{} =
                pending_aggregated_player_stats_by_tournament} =
               PendingAggregatedPlayerStatsByTournaments.create_pending_aggregated_player_stats_by_tournament(
                 attrs
               )

      assert pending_aggregated_player_stats_by_tournament.tournament_id != nil
    end

    test "create_pending_aggregated_player_stats_by_tournament/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               PendingAggregatedPlayerStatsByTournaments.create_pending_aggregated_player_stats_by_tournament(
                 @invalid_attrs
               )
    end

    test "update_pending_aggregated_player_stats_by_tournament/2 with valid data updates the pending_aggregated_player_stats_by_tournament" do
      pending_aggregated_player_stats_by_tournament =
        pending_aggregated_player_stats_by_tournament_fixture()

      assert {:ok,
              %PendingAggregatedPlayerStatsByTournament{} =
                pending_aggregated_player_stats_by_tournament} =
               PendingAggregatedPlayerStatsByTournaments.update_pending_aggregated_player_stats_by_tournament(
                 pending_aggregated_player_stats_by_tournament,
                 @update_attrs
               )

      assert pending_aggregated_player_stats_by_tournament.tournament_id != nil
    end

    test "update_pending_aggregated_player_stats_by_tournament/2 with invalid data returns error changeset" do
      pending_aggregated_player_stats_by_tournament =
        pending_aggregated_player_stats_by_tournament_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PendingAggregatedPlayerStatsByTournaments.update_pending_aggregated_player_stats_by_tournament(
                 pending_aggregated_player_stats_by_tournament,
                 @invalid_attrs
               )

      assert pending_aggregated_player_stats_by_tournament ==
               PendingAggregatedPlayerStatsByTournaments.get_pending_aggregated_player_stats_by_tournament!(
                 pending_aggregated_player_stats_by_tournament.id
               )
    end

    test "delete_pending_aggregated_player_stats_by_tournament/1 deletes the pending_aggregated_player_stats_by_tournament" do
      pending_aggregated_player_stats_by_tournament =
        pending_aggregated_player_stats_by_tournament_fixture()

      assert {:ok, %PendingAggregatedPlayerStatsByTournament{}} =
               PendingAggregatedPlayerStatsByTournaments.delete_pending_aggregated_player_stats_by_tournament(
                 pending_aggregated_player_stats_by_tournament
               )

      assert_raise Ecto.NoResultsError, fn ->
        PendingAggregatedPlayerStatsByTournaments.get_pending_aggregated_player_stats_by_tournament!(
          pending_aggregated_player_stats_by_tournament.id
        )
      end
    end

    test "change_pending_aggregated_player_stats_by_tournament/1 returns a pending_aggregated_player_stats_by_tournament changeset" do
      pending_aggregated_player_stats_by_tournament =
        pending_aggregated_player_stats_by_tournament_fixture()

      assert %Ecto.Changeset{} =
               PendingAggregatedPlayerStatsByTournaments.change_pending_aggregated_player_stats_by_tournament(
                 pending_aggregated_player_stats_by_tournament
               )
    end

    test "list_tournament_ids returns all tournament_ids" do
      pending_aggregated_player_stats_by_tournament =
        pending_aggregated_player_stats_by_tournament_fixture()

      %{tournament_id: pending_aggregated_player_stats_by_tournament.tournament_id}
      |> PendingAggregatedPlayerStatsByTournaments.create_pending_aggregated_player_stats_by_tournament()

      some_tournament =
        Tournaments.get_tournament!(pending_aggregated_player_stats_by_tournament.tournament_id)

      {:ok, another_tournament} =
        %{name: "another tournament", slug: "another-slug"}
        |> Map.merge(%{organization_id: some_tournament.organization_id})
        |> Tournaments.create_tournament()

      %{tournament_id: another_tournament.id}
      |> PendingAggregatedPlayerStatsByTournaments.create_pending_aggregated_player_stats_by_tournament()

      results = PendingAggregatedPlayerStatsByTournaments.list_tournament_ids()

      assert Enum.member?(results, some_tournament.id) == true
      assert Enum.member?(results, another_tournament.id) == true
    end

    test "delete_by_tournament_id deletes all pending_aggregated_player_stats_by_tournament pertaining to a tournament_id" do
      pending_aggregated_player_stats_by_tournament =
        pending_aggregated_player_stats_by_tournament_fixture()

      %{tournament_id: pending_aggregated_player_stats_by_tournament.tournament_id}
      |> PendingAggregatedPlayerStatsByTournaments.create_pending_aggregated_player_stats_by_tournament()

      assert {2, _} =
               PendingAggregatedPlayerStatsByTournaments.delete_by_tournament_id(
                 pending_aggregated_player_stats_by_tournament.tournament_id
               )

      assert PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament() ==
               []
    end

    test """
      run_pending_aggregated_player_stats_generation/0
      inserts aggregated player stats log for pending tournament,
      removes pending_aggregated_player_stats_by_tournament
    """ do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      [first_player_stat, second_player_stat] = tournament.player_stats

      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            first_player_stat.id => "6",
            second_player_stat.id => "2"
          }
        })

      second_valid_attrs =
        %{
          stats: %{first_player_stat.id => "4", second_player_stat.id => "3"}
        }
        |> Map.merge(%{
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      # This operation adds pending_aggregated_player_stats_by_tournament
      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      assert [tournament_id] = PendingAggregatedPlayerStatsByTournaments.list_tournament_ids()
      assert tournament_id == tournament.id

      PendingAggregatedPlayerStatsByTournaments.run_pending_aggregated_player_stats_generation()

      [aggregated_player_stats_by_tournament] =
        AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()

      assert aggregated_player_stats_by_tournament.player_id == first_valid_attrs.player_id
      assert aggregated_player_stats_by_tournament.tournament_id == tournament.id

      # Should have cleaned the pending aggregated player stats list
      assert [] == PendingAggregatedPlayerStatsByTournaments.list_tournament_ids()

      # Should set has_aggregated_player_stats of the tournament to true
      tournament_after = Tournaments.get_tournament!(tournament.id)
      assert tournament_after.has_aggregated_player_stats == true
    end
  end
end
