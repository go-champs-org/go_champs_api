defmodule GoChampsApi.Infrastructure.Jobs.GenerateGameResultsTest do
  alias GoChampsApi.Helpers.TournamentHelpers
  use GoChampsApi.DataCase

  alias GoChampsApi.Infrastructure.Jobs.GenerateGameResults

  alias GoChampsApi.Games
  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.GameHelpers
  alias GoChampsApi.Helpers.TournamentHelpers

  test "perform/1 update game for basketball" do
    {:ok, basketball_tournament} = TournamentHelpers.create_tournament_basketball_5x5()

    {:ok, home_team_stats_log} =
      %{tournament_id: basketball_tournament.id, stats: %{"points" => 100.0}}
      |> TeamHelpers.map_team_id_in_attrs()
      |> PhaseHelpers.map_phase_id_for_tournament()
      |> GameHelpers.map_game_id()
      |> TeamStatsLogs.create_team_stats_log()

    {:ok, game} =
      Games.get_game!(home_team_stats_log.game_id)
      |> GameHelpers.set_home_team_id(home_team_stats_log.team_id)

    assert GenerateGameResults.perform(%Oban.Job{args: %{"game_id" => game.id}}) ==
             {:ok, "Game results has been generated for game #{game.id}"}

    updated_game = Games.get_game!(game.id)

    assert updated_game.home_score == 100
  end
end
