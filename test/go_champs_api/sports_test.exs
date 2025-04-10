defmodule GoChampsApi.SportsTest do
  alias GoChampsApi.Sports
  use ExUnit.Case
  use GoChampsApi.DataCase

  alias GoChampsApi.Helpers.GameHelpers
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Draws
  alias GoChampsApi.Games
  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases
  alias GoChampsApi.Sports.Basketball5x5.Basketball5x5

  describe "list_sports/0" do
    test "returns all sports" do
      sports = [
        Basketball5x5.sport()
      ]

      assert Sports.list_sports() == sports
    end
  end

  describe "get_sport/1" do
    test "returns a sport by slug with associated player_stats" do
      sport = Sports.get_sport("basketball_5x5")

      assert sport.name == "Basketball 5x5"
      assert sport.slug == "basketball_5x5"
    end
  end

  describe "get_default_player_statistic_to_order_by/1" do
    test "returns the default player statistic to order by for a sport" do
      statistic = Sports.get_default_player_statistic_to_order_by("basketball_5x5")

      assert statistic.slug == "points"
      assert statistic.level == :game
      assert statistic.value_type == :calculated
    end

    test "returns nil when sport is not found" do
      assert Sports.get_default_player_statistic_to_order_by("invalid_sport") == nil
    end
  end

  describe "get_game_level_calculated_statistics!/1" do
    test "returns the list of game level calculated statistics for a sport" do
      statistics = Sports.get_game_level_calculated_statistics!("basketball_5x5")

      Enum.each(statistics, fn stat ->
        assert stat.level == :game
        assert stat.value_type == :calculated
      end)
    end

    test "returns empty list when sport is not found" do
      assert Sports.get_game_level_calculated_statistics!("invalid_sport") == []
    end
  end

  describe "get_game_against_team_level_calculated_statistics!/1" do
    test "returns the list of game against team level calculated statistics for a sport" do
      statistics = Sports.get_game_against_team_level_calculated_statistics!("basketball_5x5")

      Enum.each(statistics, fn stat ->
        assert stat.level == :game_against_team
        assert stat.value_type == :calculated
      end)
    end

    test "returns empty list when sport is not found" do
      assert Sports.get_game_against_team_level_calculated_statistics!("invalid_sport") == []
    end
  end

  describe "get_game_level_aggregated_calculated_statistics!/1" do
    test "returns the list of game level aggregated calculated statistics for a sport" do
      statistics = Sports.get_game_level_aggregated_calculated_statistics!("basketball_5x5")

      Enum.each(statistics, fn stat ->
        assert stat.level == :game
        assert stat.scope == :aggregate
        assert stat.value_type == :calculated
      end)
    end

    test "returns empty list when sport is not found" do
      assert Sports.get_game_level_aggregated_calculated_statistics!("invalid_sport") == []
    end
  end

  describe "get_tournament_level_per_game_statistics!/1" do
    test "returns the list of tournament level per game statistics for a sport" do
      statistics = Sports.get_tournament_level_per_game_statistics!("basketball_5x5")

      Enum.each(statistics, fn stat ->
        assert stat.level == :tournament
        assert stat.scope == :per_game
      end)
    end

    test "returns empty list when sport is not found" do
      assert Sports.get_tournament_level_per_game_statistics!("invalid_sport") == []
    end
  end

  describe "update_game_results/1" do
    test "does not update game results when sport is not found" do
      {:ok, tournament} = TournamentHelpers.create_simple_tournament()

      {:ok, game} =
        %{tournament_id: tournament.id}
        |> PhaseHelpers.map_phase_id()
        |> GameHelpers.create_game()

      {:ok, result_game} = Sports.update_game_results(game.id)
      assert result_game.id == game.id
      assert result_game.updated_at == game.updated_at
    end

    test "updates game results when sport is basketball_5x5" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

      {:ok, home_team_stats_log} =
        %{tournament_id: tournament.id, stats: %{"points" => 100.0}}
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> GameHelpers.map_game_id()
        |> TeamHelpers.map_team_id_in_attrs()
        |> TeamHelpers.map_against_team_id()
        |> TeamStatsLogs.create_team_stats_log()

      {:ok, game} =
        Games.get_game!(home_team_stats_log.game_id)
        |> GameHelpers.set_home_team_id(home_team_stats_log.team_id)
        |> elem(1)
        |> GameHelpers.set_away_team_id(home_team_stats_log.against_team_id)

      {:ok, result_game} = Sports.update_game_results(game.id)

      assert result_game.home_score == 100
      assert result_game.away_score == 0
    end
  end

  describe "update_draw_results/1" do
    test "does not update draw results when sport is not found" do
      {:ok, tournament} = TournamentHelpers.create_simple_tournament()

      phase =
        %{tournament_id: tournament.id, type: "draw"}
        |> PhaseHelpers.create_phase()

      {:ok, draw} =
        %{phase_id: phase.id, matches: [%{first_team_id: "team1", second_team_id: "team2"}]}
        |> Draws.create_draw()

      {:ok, result_draw} = Sports.update_draw_results(draw.id)
      assert result_draw.id == draw.id
      assert result_draw.updated_at == draw.updated_at
    end

    test "updates draw results when sport is basketball_5x5" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

      {:ok, first_team_head_to_head_stats_log} =
        %{tournament_id: tournament.id, stats: %{"wins" => 1}}
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> GameHelpers.map_game_id()
        |> TeamHelpers.map_team_id_in_attrs()
        |> TeamHelpers.map_against_team_id()
        |> AggregatedTeamHeadToHeadStatsByPhases.create_aggregated_team_head_to_head_stats_by_phase()

      {:ok, second_team_head_to_head_stats_log} =
        %{
          tournament_id: tournament.id,
          stats: %{"wins" => 2},
          phase_id: first_team_head_to_head_stats_log.phase_id,
          team_id: first_team_head_to_head_stats_log.against_team_id,
          against_team_id: first_team_head_to_head_stats_log.team_id
        }
        |> AggregatedTeamHeadToHeadStatsByPhases.create_aggregated_team_head_to_head_stats_by_phase()

      {:ok, draw} =
        %{
          phase_id: first_team_head_to_head_stats_log.phase_id,
          matches: [
            %{
              first_team_id: first_team_head_to_head_stats_log.team_id,
              first_team_score: "0",
              info: "Match Info",
              name: "Match Name",
              second_team_id: second_team_head_to_head_stats_log.team_id,
              second_team_score: "0"
            }
          ]
        }
        |> Draws.create_draw()

      {:ok, result_draw} = Sports.update_draw_results(draw.id)

      [result_match] = result_draw.matches

      assert result_match.first_team_score == "1"
      assert result_match.second_team_score == "2"
    end
  end
end
