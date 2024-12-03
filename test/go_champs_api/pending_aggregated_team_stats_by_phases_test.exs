defmodule GoChampsApi.PendingAggregatedTeamStatsByPhasesTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.PendingAggregatedTeamStatsByPhases
  alias GoChampsApi.Tournaments

  describe "pending_aggregated_team_stats_by_phase" do
    alias GoChampsApi.PendingAggregatedTeamStatsByPhases.PendingAggregatedTeamStatsByPhase

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{tournament_id: nil}

    def pending_aggregated_team_stats_by_phase_fixture(attrs \\ %{}) do
      {:ok, pending_aggregated_team_stats_by_phase} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PhaseHelpers.map_phase_id_and_tournament_id()
        |> PendingAggregatedTeamStatsByPhases.create_pending_aggregated_team_stats_by_phase()

      pending_aggregated_team_stats_by_phase
    end

    test "list_pending_aggregated_team_stats_by_phase/0 returns all pending_aggregated_team_stats_by_phase" do
      pending_aggregated_team_stats_by_phase = pending_aggregated_team_stats_by_phase_fixture()

      assert PendingAggregatedTeamStatsByPhases.list_pending_aggregated_team_stats_by_phase() == [
               pending_aggregated_team_stats_by_phase
             ]
    end

    test "get_pending_aggregated_team_stats_by_phase!/1 returns the pending_aggregated_team_stats_by_phase with given id" do
      pending_aggregated_team_stats_by_phase = pending_aggregated_team_stats_by_phase_fixture()

      assert PendingAggregatedTeamStatsByPhases.get_pending_aggregated_team_stats_by_phase!(
               pending_aggregated_team_stats_by_phase.id
             ) == pending_aggregated_team_stats_by_phase
    end

    test "create_pending_aggregated_team_stats_by_phase/1 with valid data creates a pending_aggregated_team_stats_by_phase" do
      attrs =
        @valid_attrs
        |> PhaseHelpers.map_phase_id_and_tournament_id()

      assert {:ok, %PendingAggregatedTeamStatsByPhase{} = pending_aggregated_team_stats_by_phase} =
               PendingAggregatedTeamStatsByPhases.create_pending_aggregated_team_stats_by_phase(
                 attrs
               )

      assert pending_aggregated_team_stats_by_phase.phase_id != nil
      assert pending_aggregated_team_stats_by_phase.tournament_id != nil
    end

    test "create_pending_aggregated_team_stats_by_phase/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               PendingAggregatedTeamStatsByPhases.create_pending_aggregated_team_stats_by_phase(
                 @invalid_attrs
               )
    end

    test "update_pending_aggregated_team_stats_by_phase/2 with valid data updates the pending_aggregated_team_stats_by_phase" do
      pending_aggregated_team_stats_by_phase = pending_aggregated_team_stats_by_phase_fixture()

      assert {:ok, %PendingAggregatedTeamStatsByPhase{} = pending_aggregated_team_stats_by_phase} =
               PendingAggregatedTeamStatsByPhases.update_pending_aggregated_team_stats_by_phase(
                 pending_aggregated_team_stats_by_phase,
                 @update_attrs
               )

      assert pending_aggregated_team_stats_by_phase.phase_id != nil
      assert pending_aggregated_team_stats_by_phase.tournament_id != nil
    end

    test "update_pending_aggregated_team_stats_by_phase/2 with invalid data returns error changeset" do
      pending_aggregated_team_stats_by_phase = pending_aggregated_team_stats_by_phase_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PendingAggregatedTeamStatsByPhases.update_pending_aggregated_team_stats_by_phase(
                 pending_aggregated_team_stats_by_phase,
                 @invalid_attrs
               )

      assert pending_aggregated_team_stats_by_phase ==
               PendingAggregatedTeamStatsByPhases.get_pending_aggregated_team_stats_by_phase!(
                 pending_aggregated_team_stats_by_phase.id
               )
    end

    test "delete_pending_aggregated_team_stats_by_phase/1 deletes the pending_aggregated_team_stats_by_phase" do
      pending_aggregated_team_stats_by_phase = pending_aggregated_team_stats_by_phase_fixture()

      assert {:ok, %PendingAggregatedTeamStatsByPhase{}} =
               PendingAggregatedTeamStatsByPhases.delete_pending_aggregated_team_stats_by_phase(
                 pending_aggregated_team_stats_by_phase
               )

      assert_raise Ecto.NoResultsError, fn ->
        PendingAggregatedTeamStatsByPhases.get_pending_aggregated_team_stats_by_phase!(
          pending_aggregated_team_stats_by_phase.id
        )
      end
    end

    test "change_pending_aggregated_team_stats_by_phase/1 returns a pending_aggregated_team_stats_by_phase changeset" do
      pending_aggregated_team_stats_by_phase = pending_aggregated_team_stats_by_phase_fixture()

      assert %Ecto.Changeset{} =
               PendingAggregatedTeamStatsByPhases.change_pending_aggregated_team_stats_by_phase(
                 pending_aggregated_team_stats_by_phase
               )
    end

    test "list_tournament_ids returns all tournament_ids" do
      pending_aggregated_team_stats_by_phase = pending_aggregated_team_stats_by_phase_fixture()

      %{
        tournament_id: pending_aggregated_team_stats_by_phase.tournament_id,
        phase_id: pending_aggregated_team_stats_by_phase.phase_id
      }
      |> PendingAggregatedTeamStatsByPhases.create_pending_aggregated_team_stats_by_phase()

      some_tournament =
        Tournaments.get_tournament!(pending_aggregated_team_stats_by_phase.tournament_id)

      {:ok, another_tournament} =
        %{name: "another tournament", slug: "another-slug"}
        |> Map.merge(%{organization_id: some_tournament.organization_id})
        |> Tournaments.create_tournament()

      %{
        tournament_id: another_tournament.id,
        phase_id: pending_aggregated_team_stats_by_phase.phase_id
      }
      |> PendingAggregatedTeamStatsByPhases.create_pending_aggregated_team_stats_by_phase()

      results = PendingAggregatedTeamStatsByPhases.list_tournament_ids()

      assert Enum.member?(results, some_tournament.id) == true
      assert Enum.member?(results, another_tournament.id) == true
    end

    test "delete_by_tournament_id deletes all pending_aggregated_team_stats_by_phase pertaining to a tournament_id" do
      pending_aggregated_team_stats_by_phase = pending_aggregated_team_stats_by_phase_fixture()

      %{
        tournament_id: pending_aggregated_team_stats_by_phase.tournament_id,
        phase_id: pending_aggregated_team_stats_by_phase.phase_id
      }
      |> PendingAggregatedTeamStatsByPhases.create_pending_aggregated_team_stats_by_phase()

      assert {2, _} =
               PendingAggregatedTeamStatsByPhases.delete_by_tournament_id(
                 pending_aggregated_team_stats_by_phase.tournament_id
               )

      assert PendingAggregatedTeamStatsByPhases.list_pending_aggregated_team_stats_by_phase() ==
               []
    end

    # test """
    #   run_pending_aggregated_team_stats_generation/0
    #   inserts aggregated player stats log for pending tournament,
    #   removes pending_aggregated_team_stats_by_phase
    # """ do
    #   valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
    #   assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

    #   [first_team_stat, second_team_stat] = tournament.team_stats

    #   {:ok, %Phase{} = phase} =
    #     Map.merge(@valid_phase_attrs, %{tournament_id: tournament.id})
    #     |> Phases.create_phase()

    #   first_valid_attrs =
    #     TeamHelpers.map_team_id(tournament.id, %{
    #       phase_id: phase.id,
    #       stats: %{
    #         first_team_stat.id => "6",
    #         second_team_stat.id => "2"
    #       }
    #     })

    #   second_valid_attrs =
    #     %{
    #       stats: %{first_team_stat.id => "4", second_team_stat.id => "3"}
    #     }
    #     |> Map.merge(%{
    #       phase_id: first_valid_attrs.phase_id,
    #       team_id: first_valid_attrs.team_id,
    #       tournament_id: first_valid_attrs.tournament_id
    #     })

    #   # This operation adds pending_aggregated_team_stats_by_phase
    #   assert {:ok, batch_results} =
    #            TeamStatsLogs.create_team_stats_logs([first_valid_attrs, second_valid_attrs])

    #   assert [tournament_id] = PendingAggregatedTeamStatsByPhases.list_tournament_ids()
    #   assert tournament_id == tournament.id

    #   PendingAggregatedTeamStatsByPhases.run_pending_aggregated_team_stats_generation()

    #   [aggregated_team_stats_by_phase] =
    #     AggregatedTeamStatsByPhases.list_aggregated_team_stats_by_phase()

    #   assert aggregated_team_stats_by_phase.player_id == first_valid_attrs.player_id
    #   assert aggregated_team_stats_by_phase.tournament_id == tournament.id

    #   # Should have cleaned the pending aggregated player stats list
    #   assert [] == PendingAggregatedTeamStatsByPhases.list_tournament_ids()
    # end
  end
end
