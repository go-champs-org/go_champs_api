defmodule GoChampsApi.AggregatedTeamStatsByPhasesTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Helpers.OrganizationHelpers
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers

  describe "aggregated_team_stats_by_phase" do
    alias GoChampsApi.AggregatedTeamStatsByPhases.AggregatedTeamStatsByPhase

    @valid_attrs %{stats: %{"some" => "8"}}
    @update_attrs %{
      stats: %{"some" => "10"}
    }
    @invalid_attrs %{player_id: nil, stats: nil, tournament_id: nil}
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

    test "list_aggregated_team_stats_by_phase/1 returns all aggregated_team_stats_by_phase with given where" do
      aggregated_team_stats_by_phase = aggregated_team_stats_by_phase_fixture()

      assert AggregatedTeamStatsByPhases.list_aggregated_team_stats_by_phase(
               [
                 tournament_id: aggregated_team_stats_by_phase.tournament_id,
                 phase_id: aggregated_team_stats_by_phase.phase_id
               ],
               "some"
             ) == [aggregated_team_stats_by_phase]
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

    test "generate_aggregated_team_stats_for_phase/1 inserts aggregated team stats" do
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
        |> PhaseHelpers.map_phase_id_for_tournament()

      second_base_valid_attrs = %{
        tournament_id: tournament.id,
        team_id: first_valid_attrs.team_id,
        phase_id: first_valid_attrs.phase_id,
        stats: %{
          first_team_stat.id => 4,
          second_team_stat.id => 6
        }
      }

      TeamStatsLogs.create_team_stats_logs([first_valid_attrs, second_base_valid_attrs])

      AggregatedTeamStatsByPhases.generate_aggregated_team_stats_for_phase(
        first_valid_attrs.phase_id
      )

      where = [tournament_id: tournament.id, phase_id: first_valid_attrs.phase_id]

      [first_aggregated] =
        AggregatedTeamStatsByPhases.list_aggregated_team_stats_by_phase(
          where,
          first_team_stat.id
        )

      assert first_aggregated.stats == %{
               first_team_stat.id => 10.0,
               second_team_stat.id => 8.0
             }

      assert first_aggregated.tournament_id == tournament.id
      assert first_aggregated.phase_id == first_valid_attrs.phase_id
      assert first_aggregated.team_id == first_valid_attrs.team_id
    end

    test "aggregate_team_stats_from_team_stats_logs/1 aggregates team stats" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      [first_team_stat, second_team_stat | _tail] = tournament.team_stats

      first_base_valid_attrs = %{
        tournament_id: tournament.id,
        stats: %{
          first_team_stat.id => 6,
          second_team_stat.id => 2,
          "some" => 3
        }
      }

      first_valid_attrs =
        TeamHelpers.map_team_id(tournament.id, first_base_valid_attrs)
        |> PhaseHelpers.map_phase_id_for_tournament()

      second_base_valid_attrs = %{
        tournament_id: tournament.id,
        team_id: first_valid_attrs.team_id,
        phase_id: first_valid_attrs.phase_id,
        stats: %{
          first_team_stat.id => 4,
          second_team_stat.id => 6,
          "some" => 3
        }
      }

      TeamStatsLogs.create_team_stats_logs([first_valid_attrs, second_base_valid_attrs])

      team_stats_logs = TeamStatsLogs.list_team_stats_log()

      aggregated_team_stats =
        AggregatedTeamStatsByPhases.aggregate_team_stats_from_team_stats_logs(
          [first_team_stat.id, second_team_stat.id, "some"],
          team_stats_logs
        )

      assert aggregated_team_stats == %{
               first_team_stat.id => 10.0,
               second_team_stat.id => 8.0,
               "some" => 6.0
             }
    end
  end
end
