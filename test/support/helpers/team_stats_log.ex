defmodule GoChampsApi.Helpers.TeamStatsLogHelper do
  alias GoChampsApi.Helpers.GameHelpers
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.TeamStatsLogs

  def create_team_stats_log_for_tournament_with_sport(team_stats_values \\ []) do
    {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

    team_stats =
      Enum.reduce(team_stats_values, %{}, fn {team_stat_slug, value}, acc ->
        Map.put(acc, team_stat_slug, value)
      end)

    {:ok, team_stats_log} =
      %{
        tournament_id: tournament.id,
        stats: team_stats
      }
      |> TeamHelpers.map_team_id_in_attrs()
      |> TeamHelpers.map_against_team_id()
      |> PhaseHelpers.map_phase_id()
      |> GameHelpers.map_game_id()
      |> TeamStatsLogs.create_team_stats_log()

    team_stats_log
  end
end
