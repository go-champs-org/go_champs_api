defmodule GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGameTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame

  alias GoChampsApi.Games
  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.Helpers.GameHelpers
  alias GoChampsApi.Helpers.PlayerStatsLogHelper

  test "perform/1" do
    player_stats_log =
      PlayerStatsLogHelper.create_player_stats_log_for_tournament_with_sport([
        {"rebounds_defensive", "10"},
        {"rebounds_offensive", "5"}
      ])

    Games.get_game!(player_stats_log.game_id)
    |> GameHelpers.set_home_team_id(player_stats_log.team_id)
    |> elem(1)
    |> GameHelpers.set_away_team_id(player_stats_log.team_id)

    {:ok, _} =
      GenerateTeamStatsLogsForGame.perform(%Oban.Job{
        args: %{"game_id" => player_stats_log.game_id}
      })

    [team_stats_log] =
      TeamStatsLogs.list_team_stats_log(
        game_id: player_stats_log.game_id,
        team_id: player_stats_log.team_id
      )

    assert team_stats_log.stats["rebounds"] == 15.0
    assert team_stats_log.stats["rebounds_defensive"] == 10.0
    assert team_stats_log.stats["rebounds_offensive"] == 5.0
  end
end
