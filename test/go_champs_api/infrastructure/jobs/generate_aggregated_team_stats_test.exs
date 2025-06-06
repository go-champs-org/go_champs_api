defmodule GoChampsApi.Infrastructure.Jobs.GenerateAggregatedTeamStatsTest do
  alias GoChampsApi.Helpers.TournamentHelpers
  use GoChampsApi.DataCase
  alias GoChampsApi.Infrastructure.Jobs.GenerateAggregatedTeamStats

  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases
  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.GameHelpers

  test "perform/1" do
    {:ok, basketball_tournament} = TournamentHelpers.create_tournament_basketball_5x5()

    {:ok, first_team_stats} =
      %{tournament_id: basketball_tournament.id, stats: %{"points" => 10}}
      |> TeamHelpers.map_team_id_in_attrs()
      |> TeamHelpers.map_against_team_id()
      |> PhaseHelpers.map_phase_id_for_tournament()
      |> GameHelpers.map_game_id()
      |> TeamStatsLogs.create_team_stats_log()

    {:ok, _second_team_stats} =
      %{
        stats: %{"points" => 20},
        team_id: first_team_stats.team_id,
        against_team_id: first_team_stats.against_team_id,
        tournament_id: first_team_stats.tournament_id,
        phase_id: first_team_stats.phase_id
      }
      |> GameHelpers.map_game_id()
      |> TeamStatsLogs.create_team_stats_log()

    {:ok, _} =
      GenerateAggregatedTeamStats.perform(%Oban.Job{
        args: %{"phase_id" => first_team_stats.phase_id}
      })

    [aggregated_team_stats] =
      AggregatedTeamStatsByPhases.list_aggregated_team_stats_by_phase(
        [phase_id: first_team_stats.phase_id],
        "points"
      )

    [aggregated_team_head_to_head_stats] =
      AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase(
        phase_id: first_team_stats.phase_id
      )

    assert aggregated_team_stats.team_id == first_team_stats.team_id
    assert aggregated_team_stats.stats["points"] == 30
    assert aggregated_team_head_to_head_stats.team_id == first_team_stats.team_id

    assert aggregated_team_head_to_head_stats.against_team_id ==
             first_team_stats.against_team_id

    assert aggregated_team_head_to_head_stats.stats["points"] == 30
    assert aggregated_team_head_to_head_stats.phase_id == first_team_stats.phase_id
  end

  test "perform/1 does't not duplicated records for same phase" do
    {:ok, basketball_tournament} = TournamentHelpers.create_tournament_basketball_5x5()

    {:ok, first_team_stats} =
      %{tournament_id: basketball_tournament.id, stats: %{"points" => 10}}
      |> TeamHelpers.map_team_id_in_attrs()
      |> TeamHelpers.map_against_team_id()
      |> PhaseHelpers.map_phase_id_for_tournament()
      |> GameHelpers.map_game_id()
      |> TeamStatsLogs.create_team_stats_log()

    {:ok, _second_team_stats} =
      %{
        stats: %{"points" => 20},
        team_id: first_team_stats.team_id,
        against_team_id: first_team_stats.against_team_id,
        tournament_id: first_team_stats.tournament_id,
        phase_id: first_team_stats.phase_id
      }
      |> GameHelpers.map_game_id()
      |> TeamStatsLogs.create_team_stats_log()

    {:ok, _} =
      GenerateAggregatedTeamStats.perform(%Oban.Job{
        args: %{"phase_id" => first_team_stats.phase_id}
      })

    {:ok, _} =
      GenerateAggregatedTeamStats.perform(%Oban.Job{
        args: %{"phase_id" => first_team_stats.phase_id}
      })

    [aggregated_team_stats] =
      AggregatedTeamStatsByPhases.list_aggregated_team_stats_by_phase(
        [phase_id: first_team_stats.phase_id],
        "points"
      )

    [aggregated_team_head_to_head_stats] =
      AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase(
        phase_id: first_team_stats.phase_id
      )

    assert aggregated_team_stats.team_id == first_team_stats.team_id
    assert aggregated_team_stats.stats["points"] == 30
    assert aggregated_team_head_to_head_stats.team_id == first_team_stats.team_id

    assert aggregated_team_head_to_head_stats.against_team_id ==
             first_team_stats.against_team_id

    assert aggregated_team_head_to_head_stats.stats["points"] == 30
    assert aggregated_team_head_to_head_stats.phase_id == first_team_stats.phase_id
  end
end
