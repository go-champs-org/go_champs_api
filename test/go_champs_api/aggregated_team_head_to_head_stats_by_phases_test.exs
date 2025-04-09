defmodule GoChampsApi.AggregatedTeamHeadToHeadStatsByPhasesTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.Helpers.{OrganizationHelpers, TeamHelpers, PhaseHelpers}

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
    @valid_tournament_attrs %{
      name: "some name",
      slug: "some-slug",
      team_stats: [
        %{
          title: "some stat"
        },
        %{
          title: "another stat"
        }
      ],
      sport_slug: "basketball_5x5"
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

    test "list_aggregated_team_head_to_head_stats_by_phase/1 returns all aggregated_team_head_to_head_stats_by_phase with given where" do
      aggregated_team_head_to_head_stats_by_phase =
        aggregated_team_head_to_head_stats_by_phase_fixture()

      assert AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase(
               tournament_id: aggregated_team_head_to_head_stats_by_phase.tournament_id,
               phase_id: aggregated_team_head_to_head_stats_by_phase.phase_id
             ) == [aggregated_team_head_to_head_stats_by_phase]
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

    test "generate_aggregated_team_head_to_head_stats_by_phase/1 inserts aggregated team head to head stats" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      [first_team_stat, second_team_stat | _tail] = tournament.team_stats

      first_base_valid_attrs = %{
        tournament_id: tournament.id,
        stats: %{
          first_team_stat.id => 6,
          second_team_stat.id => 2
        }
      }

      first_valid_attrs =
        TeamHelpers.map_team_id(tournament.id, first_base_valid_attrs)
        |> TeamHelpers.map_against_team_id()
        |> PhaseHelpers.map_phase_id_for_tournament()

      second_base_valid_attrs = %{
        tournament_id: tournament.id,
        team_id: first_valid_attrs.team_id,
        against_team_id: first_valid_attrs.against_team_id,
        phase_id: first_valid_attrs.phase_id,
        stats: %{
          first_team_stat.id => 4,
          second_team_stat.id => 6
        }
      }

      TeamStatsLogs.create_team_stats_logs([first_valid_attrs, second_base_valid_attrs])

      :ok =
        AggregatedTeamHeadToHeadStatsByPhases.generate_aggregated_team_head_to_head_stats_by_phase(
          first_valid_attrs.phase_id
        )

      where = [
        tournament_id: tournament.id,
        phase_id: first_valid_attrs.phase_id,
        team_id: first_valid_attrs.team_id
      ]

      assert [aggregated_team_head_to_head_stats_by_phase] =
               AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase(
                 where
               )

      assert aggregated_team_head_to_head_stats_by_phase.against_team_id ==
               first_valid_attrs.against_team_id

      assert aggregated_team_head_to_head_stats_by_phase.phase_id == first_valid_attrs.phase_id

      assert aggregated_team_head_to_head_stats_by_phase.stats == %{
               first_team_stat.id => 10,
               second_team_stat.id => 8
             }
    end

    test "generate_aggregated_team_head_to_head_stats_by_phase/1 inserts aggregated team head to head stats for each against team" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      [first_team_stat, second_team_stat | _tail] = tournament.team_stats

      first_base_valid_attrs = %{
        tournament_id: tournament.id,
        stats: %{
          first_team_stat.id => 6,
          second_team_stat.id => 2
        }
      }

      first_valid_attrs =
        TeamHelpers.map_team_id(tournament.id, first_base_valid_attrs)
        |> TeamHelpers.map_against_team_id()
        |> PhaseHelpers.map_phase_id_for_tournament()

      second_base_valid_attrs =
        %{
          tournament_id: tournament.id,
          team_id: first_valid_attrs.team_id,
          phase_id: first_valid_attrs.phase_id,
          stats: %{
            first_team_stat.id => 4,
            second_team_stat.id => 6
          }
        }
        |> TeamHelpers.map_against_team_id()

      third_base_valid_attrs = %{
        tournament_id: tournament.id,
        team_id: first_valid_attrs.team_id,
        against_team_id: second_base_valid_attrs.against_team_id,
        phase_id: first_valid_attrs.phase_id,
        stats: %{
          first_team_stat.id => 3,
          second_team_stat.id => 5
        }
      }

      TeamStatsLogs.create_team_stats_logs([
        first_valid_attrs,
        second_base_valid_attrs,
        third_base_valid_attrs
      ])

      :ok =
        AggregatedTeamHeadToHeadStatsByPhases.generate_aggregated_team_head_to_head_stats_by_phase(
          first_valid_attrs.phase_id
        )

      first_against_team_where = [
        tournament_id: tournament.id,
        phase_id: first_valid_attrs.phase_id,
        team_id: first_valid_attrs.team_id,
        against_team_id: first_valid_attrs.against_team_id
      ]

      second_against_team_where = [
        tournament_id: tournament.id,
        phase_id: first_valid_attrs.phase_id,
        team_id: first_valid_attrs.team_id,
        against_team_id: second_base_valid_attrs.against_team_id
      ]

      assert [
               first_aggregated_team_head_to_head_stats_by_phase
             ] =
               AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase(
                 first_against_team_where
               )

      assert [
               second_aggregated_team_head_to_head_stats_by_phase
             ] =
               AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase(
                 second_against_team_where
               )

      assert first_aggregated_team_head_to_head_stats_by_phase.against_team_id ==
               first_valid_attrs.against_team_id

      assert first_aggregated_team_head_to_head_stats_by_phase.phase_id ==
               first_valid_attrs.phase_id

      assert first_aggregated_team_head_to_head_stats_by_phase.stats == %{
               first_team_stat.id => 6,
               second_team_stat.id => 2
             }

      assert second_aggregated_team_head_to_head_stats_by_phase.against_team_id ==
               second_base_valid_attrs.against_team_id

      assert second_aggregated_team_head_to_head_stats_by_phase.phase_id ==
               first_valid_attrs.phase_id

      assert second_aggregated_team_head_to_head_stats_by_phase.stats == %{
               first_team_stat.id => 7,
               second_team_stat.id => 11
             }
    end
  end
end
