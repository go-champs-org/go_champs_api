defmodule GoChampsApi.AggregatedTeamStatsByPhasesTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers

  describe "aggregated_team_stats_by_phase" do
    alias GoChampsApi.AggregatedTeamStatsByPhases.AggregatedTeamStatsByPhase

    @valid_attrs %{stats: %{"some" => "8"}}
    @update_attrs %{
      stats: %{"some" => "10"}
    }
    @invalid_attrs %{player_id: nil, stats: nil, tournament_id: nil}

    def aggregated_team_stats_by_phase_fixture(attrs \\ %{}) do
      {:ok, aggregated_team_stats_by_phase} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TeamHelpers.map_team_id_and_tournament_id()
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> AggregatedTeamStatsByPhases.create_aggregated_team_stats_by_phase()

      aggregated_team_stats_by_phase
    end

    test "list_aggregated_team_stats_by_phase/0 returns all aggregated_team_stats_by_phase" do
      aggregated_team_stats_by_phase = aggregated_team_stats_by_phase_fixture()

      assert AggregatedTeamStatsByPhases.list_aggregated_team_stats_by_phase() == [
               aggregated_team_stats_by_phase
             ]
    end

    test "get_aggregated_team_stats_by_phase!/1 returns the aggregated_team_stats_by_phase with given id" do
      aggregated_team_stats_by_phase = aggregated_team_stats_by_phase_fixture()

      assert AggregatedTeamStatsByPhases.get_aggregated_team_stats_by_phase!(
               aggregated_team_stats_by_phase.id
             ) == aggregated_team_stats_by_phase
    end

    test "create_aggregated_team_stats_by_phase/1 with valid data creates a aggregated_team_stats_by_phase" do
      valid_attrs =
        @valid_attrs
        |> TeamHelpers.map_team_id_and_tournament_id()
        |> PhaseHelpers.map_phase_id_for_tournament()

      assert {:ok, %AggregatedTeamStatsByPhase{} = aggregated_team_stats_by_phase} =
               AggregatedTeamStatsByPhases.create_aggregated_team_stats_by_phase(valid_attrs)

      assert aggregated_team_stats_by_phase.stats == %{"some" => "8"}
    end

    test "create_aggregated_team_stats_by_phase/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               AggregatedTeamStatsByPhases.create_aggregated_team_stats_by_phase(@invalid_attrs)
    end

    test "update_aggregated_team_stats_by_phase/2 with valid data updates the aggregated_team_stats_by_phase" do
      aggregated_team_stats_by_phase = aggregated_team_stats_by_phase_fixture()

      assert {:ok, %AggregatedTeamStatsByPhase{} = aggregated_team_stats_by_phase} =
               AggregatedTeamStatsByPhases.update_aggregated_team_stats_by_phase(
                 aggregated_team_stats_by_phase,
                 @update_attrs
               )

      assert aggregated_team_stats_by_phase.stats == %{"some" => "10"}
    end

    test "update_aggregated_team_stats_by_phase/2 with invalid data returns error changeset" do
      aggregated_team_stats_by_phase = aggregated_team_stats_by_phase_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AggregatedTeamStatsByPhases.update_aggregated_team_stats_by_phase(
                 aggregated_team_stats_by_phase,
                 @invalid_attrs
               )

      assert aggregated_team_stats_by_phase ==
               AggregatedTeamStatsByPhases.get_aggregated_team_stats_by_phase!(
                 aggregated_team_stats_by_phase.id
               )
    end

    test "delete_aggregated_team_stats_by_phase/1 deletes the aggregated_team_stats_by_phase" do
      aggregated_team_stats_by_phase = aggregated_team_stats_by_phase_fixture()

      assert {:ok, %AggregatedTeamStatsByPhase{}} =
               AggregatedTeamStatsByPhases.delete_aggregated_team_stats_by_phase(
                 aggregated_team_stats_by_phase
               )

      assert_raise Ecto.NoResultsError, fn ->
        AggregatedTeamStatsByPhases.get_aggregated_team_stats_by_phase!(
          aggregated_team_stats_by_phase.id
        )
      end
    end

    test "change_aggregated_team_stats_by_phase/1 returns a aggregated_team_stats_by_phase changeset" do
      aggregated_team_stats_by_phase = aggregated_team_stats_by_phase_fixture()

      assert %Ecto.Changeset{} =
               AggregatedTeamStatsByPhases.change_aggregated_team_stats_by_phase(
                 aggregated_team_stats_by_phase
               )
    end
  end
end
