defmodule GoChampsApi.AggregatedTeamHeadToHeadStatsByPhasesTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases

  describe "aggregated_team_head_to_head_stats_by_phase" do
    alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases.AggregatedTeamHeadToHeadStatsByPhase

    @valid_attrs %{
      against_team_id: "7488a646-e31f-11e4-aace-600308960662",
      phase_id: "7488a646-e31f-11e4-aace-600308960662",
      stats: %{},
      team_id: "7488a646-e31f-11e4-aace-600308960662",
      tournament_id: "7488a646-e31f-11e4-aace-600308960662"
    }
    @update_attrs %{
      against_team_id: "7488a646-e31f-11e4-aace-600308960668",
      phase_id: "7488a646-e31f-11e4-aace-600308960668",
      stats: %{},
      team_id: "7488a646-e31f-11e4-aace-600308960668",
      tournament_id: "7488a646-e31f-11e4-aace-600308960668"
    }
    @invalid_attrs %{
      against_team_id: nil,
      phase_id: nil,
      stats: nil,
      team_id: nil,
      tournament_id: nil
    }

    def aggregated_team_head_to_head_stats_by_phase_fixture(attrs \\ %{}) do
      {:ok, aggregated_team_head_to_head_stats_by_phase} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AggregatedTeamHeadToHeadStatsByPhases.create_aggregated_team_head_to_head_stats_by_phase()

      aggregated_team_head_to_head_stats_by_phase
    end

    test "list_aggregated_team_head_to_head_stats_by_phase/0 returns all aggregated_team_head_to_head_stats_by_phase" do
      aggregated_team_head_to_head_stats_by_phase =
        aggregated_team_head_to_head_stats_by_phase_fixture()

      assert AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase() ==
               [aggregated_team_head_to_head_stats_by_phase]
    end

    test "get_aggregated_team_head_to_head_stats_by_phase!/1 returns the aggregated_team_head_to_head_stats_by_phase with given id" do
      aggregated_team_head_to_head_stats_by_phase =
        aggregated_team_head_to_head_stats_by_phase_fixture()

      assert AggregatedTeamHeadToHeadStatsByPhases.get_aggregated_team_head_to_head_stats_by_phase!(
               aggregated_team_head_to_head_stats_by_phase.id
             ) == aggregated_team_head_to_head_stats_by_phase
    end

    test "create_aggregated_team_head_to_head_stats_by_phase/1 with valid data creates a aggregated_team_head_to_head_stats_by_phase" do
      assert {:ok,
              %AggregatedTeamHeadToHeadStatsByPhase{} =
                aggregated_team_head_to_head_stats_by_phase} =
               AggregatedTeamHeadToHeadStatsByPhases.create_aggregated_team_head_to_head_stats_by_phase(
                 @valid_attrs
               )

      assert aggregated_team_head_to_head_stats_by_phase.against_team_id ==
               "7488a646-e31f-11e4-aace-600308960662"

      assert aggregated_team_head_to_head_stats_by_phase.phase_id ==
               "7488a646-e31f-11e4-aace-600308960662"

      assert aggregated_team_head_to_head_stats_by_phase.stats == %{}

      assert aggregated_team_head_to_head_stats_by_phase.team_id ==
               "7488a646-e31f-11e4-aace-600308960662"

      assert aggregated_team_head_to_head_stats_by_phase.tournament_id ==
               "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_aggregated_team_head_to_head_stats_by_phase/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               AggregatedTeamHeadToHeadStatsByPhases.create_aggregated_team_head_to_head_stats_by_phase(
                 @invalid_attrs
               )
    end

    test "update_aggregated_team_head_to_head_stats_by_phase/2 with valid data updates the aggregated_team_head_to_head_stats_by_phase" do
      aggregated_team_head_to_head_stats_by_phase =
        aggregated_team_head_to_head_stats_by_phase_fixture()

      assert {:ok,
              %AggregatedTeamHeadToHeadStatsByPhase{} =
                aggregated_team_head_to_head_stats_by_phase} =
               AggregatedTeamHeadToHeadStatsByPhases.update_aggregated_team_head_to_head_stats_by_phase(
                 aggregated_team_head_to_head_stats_by_phase,
                 @update_attrs
               )

      assert aggregated_team_head_to_head_stats_by_phase.against_team_id ==
               "7488a646-e31f-11e4-aace-600308960668"

      assert aggregated_team_head_to_head_stats_by_phase.phase_id ==
               "7488a646-e31f-11e4-aace-600308960668"

      assert aggregated_team_head_to_head_stats_by_phase.stats == %{}

      assert aggregated_team_head_to_head_stats_by_phase.team_id ==
               "7488a646-e31f-11e4-aace-600308960668"

      assert aggregated_team_head_to_head_stats_by_phase.tournament_id ==
               "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_aggregated_team_head_to_head_stats_by_phase/2 with invalid data returns error changeset" do
      aggregated_team_head_to_head_stats_by_phase =
        aggregated_team_head_to_head_stats_by_phase_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AggregatedTeamHeadToHeadStatsByPhases.update_aggregated_team_head_to_head_stats_by_phase(
                 aggregated_team_head_to_head_stats_by_phase,
                 @invalid_attrs
               )

      assert aggregated_team_head_to_head_stats_by_phase ==
               AggregatedTeamHeadToHeadStatsByPhases.get_aggregated_team_head_to_head_stats_by_phase!(
                 aggregated_team_head_to_head_stats_by_phase.id
               )
    end

    test "delete_aggregated_team_head_to_head_stats_by_phase/1 deletes the aggregated_team_head_to_head_stats_by_phase" do
      aggregated_team_head_to_head_stats_by_phase =
        aggregated_team_head_to_head_stats_by_phase_fixture()

      assert {:ok, %AggregatedTeamHeadToHeadStatsByPhase{}} =
               AggregatedTeamHeadToHeadStatsByPhases.delete_aggregated_team_head_to_head_stats_by_phase(
                 aggregated_team_head_to_head_stats_by_phase
               )

      assert_raise Ecto.NoResultsError, fn ->
        AggregatedTeamHeadToHeadStatsByPhases.get_aggregated_team_head_to_head_stats_by_phase!(
          aggregated_team_head_to_head_stats_by_phase.id
        )
      end
    end

    test "change_aggregated_team_head_to_head_stats_by_phase/1 returns a aggregated_team_head_to_head_stats_by_phase changeset" do
      aggregated_team_head_to_head_stats_by_phase =
        aggregated_team_head_to_head_stats_by_phase_fixture()

      assert %Ecto.Changeset{} =
               AggregatedTeamHeadToHeadStatsByPhases.change_aggregated_team_head_to_head_stats_by_phase(
                 aggregated_team_head_to_head_stats_by_phase
               )
    end
  end
end
