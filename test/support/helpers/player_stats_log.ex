defmodule GoChampsApi.Helpers.PlayerStatsLogHelper do
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.GameHelpers
  alias GoChampsApi.Helpers.PlayerHelpers
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.PlayerStatsLogs

  def create_player_stats_log_for_tournament_with_sport(player_stats_values \\ []) do
    {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()
    {:ok, player} = PlayerHelpers.create_player_for_tournament(tournament.id)

    player_stats =
      Enum.reduce(player_stats_values, %{}, fn {player_stat_slug, value}, acc ->
        Map.put(acc, player_stat_slug, value)
      end)

    {:ok, player_stats_log} =
      %{
        player_id: player.id,
        tournament_id: tournament.id,
        stats: player_stats
      }
      |> PhaseHelpers.map_phase_id()
      |> GameHelpers.map_game_id()
      |> TeamHelpers.map_team_id_in_attrs()
      |> PlayerStatsLogs.create_player_stats_log()

    player_stats_log
  end
end
