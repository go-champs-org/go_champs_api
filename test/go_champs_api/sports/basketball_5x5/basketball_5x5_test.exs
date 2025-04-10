defmodule GoChampsApi.Sports.Basketball5x5.Basketball5x5Test do
  alias GoChampsApi.Sports.Basketball5x5.Basketball5x5
  use GoChampsApi.DataCase
  use ExUnit.Case

  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases
  alias GoChampsApi.Draws
  alias GoChampsApi.Games
  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.GameHelpers
  alias GoChampsApi.Helpers.TournamentHelpers

  describe "sport/0" do
    test "returns basketball 5x5 sport" do
      sport = Basketball5x5.sport()

      assert sport.name == "Basketball 5x5"
      assert sport.slug == "basketball_5x5"
    end

    test "returns all player statistics" do
      expected_statistics = [
        "assists",
        "blocks",
        "disqualifications",
        "ejections",
        "efficiency",
        "field_goal_percentage",
        "field_goals_attempted",
        "field_goals_made",
        "field_goals_missed",
        "fouls",
        "fouls_flagrant",
        "fouls_personal",
        "fouls_technical",
        "free_throw_percentage",
        "free_throws_attempted",
        "free_throws_made",
        "free_throws_missed",
        "game_played",
        "game_started",
        "minutes_played",
        "plus_minus",
        "points",
        "rebounds",
        "rebounds_defensive",
        "rebounds_offensive",
        "steals",
        "three_point_field_goal_percentage",
        "three_point_field_goals_attempted",
        "three_point_field_goals_made",
        "three_point_field_goals_missed",
        "turnovers",
        "assists_per_game",
        "blocks_per_game",
        "disqualifications_per_game",
        "ejections_per_game",
        "efficiency_per_game",
        "field_goal_percentage_per_game",
        "field_goals_attempted_per_game",
        "field_goals_made_per_game",
        "field_goals_missed_per_game",
        "fouls_per_game",
        "fouls_flagrant_per_game",
        "fouls_personal_per_game",
        "fouls_technical_per_game",
        "free_throw_percentage_per_game",
        "free_throws_attempted_per_game",
        "free_throws_made_per_game",
        "free_throws_missed_per_game",
        "game_started_per_game",
        "minutes_played_per_game",
        "plus_minus_per_game",
        "points_per_game",
        "rebounds_per_game",
        "rebounds_defensive_per_game",
        "rebounds_offensive_per_game",
        "steals_per_game",
        "three_point_field_goal_percentage_per_game",
        "three_point_field_goals_attempted_per_game",
        "three_point_field_goals_made_per_game",
        "three_point_field_goals_missed_per_game",
        "turnovers_per_game"
      ]

      resulted_statistics_slugs =
        Basketball5x5.sport().player_statistics
        |> Enum.map(fn statistic -> statistic.slug end)

      assert resulted_statistics_slugs == expected_statistics
    end
  end

  describe "update_draw_results/1" do
    test "updates draw results with aggregated head to head team stats" do
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

      {:ok, result_draw} = Basketball5x5.update_draw_results(draw)

      [result_match] = result_draw.matches

      assert result_match.first_team_score == "1"
      assert result_match.second_team_score == "2"
    end

    test "does not update when match has no team id" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

      {:ok, draw} =
        %{
          tournament_id: tournament.id,
          matches: [
            %{
              first_team_id: nil,
              first_team_score: "0",
              first_team_placeholder: "Placeholder",
              info: "Match Info",
              name: "Match Name",
              second_team_id: nil,
              second_team_score: "0",
              second_team_placeholder: "Placeholder"
            }
          ]
        }
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> Draws.create_draw()

      {:ok, result_draw} = Basketball5x5.update_draw_results(draw)

      [result_match] = result_draw.matches

      assert result_match.first_team_score == "0"
      assert result_match.second_team_score == "0"
    end
  end

  describe "team_wins_from_aggregated_team_head_to_head_stats/1" do
    test "returns wins value from aggregated team head to head stats" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

      {:ok, team_head_to_head_stats_log} =
        %{tournament_id: tournament.id, stats: %{"wins" => 1}}
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> TeamHelpers.map_team_id_in_attrs()
        |> TeamHelpers.map_against_team_id()
        |> AggregatedTeamHeadToHeadStatsByPhases.create_aggregated_team_head_to_head_stats_by_phase()

      assert Basketball5x5.team_wins_from_aggregated_team_head_to_head_stats(
               team_head_to_head_stats_log.phase_id,
               team_head_to_head_stats_log.team_id,
               team_head_to_head_stats_log.against_team_id
             ) == 1
    end

    test "returns 0 if no aggregated team head to head stats found" do
      assert Basketball5x5.team_wins_from_aggregated_team_head_to_head_stats(
               Ecto.UUID.generate(),
               Ecto.UUID.generate(),
               Ecto.UUID.generate()
             ) == 0
    end

    test "returns 0 when team_id is nil" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

      phase = PhaseHelpers.create_phase(%{tournament_id: tournament.id, type: "draw"})

      assert Basketball5x5.team_wins_from_aggregated_team_head_to_head_stats(
               phase.id,
               nil,
               Ecto.UUID.generate()
             ) == 0
    end

    test "returns 0 when against_team_id is nil" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

      phase = PhaseHelpers.create_phase(%{tournament_id: tournament.id, type: "draw"})

      assert Basketball5x5.team_wins_from_aggregated_team_head_to_head_stats(
               phase.id,
               Ecto.UUID.generate(),
               nil
             ) == 0
    end

    test "returns 0 when team_id and against_team_id are nil" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

      phase = PhaseHelpers.create_phase(%{tournament_id: tournament.id, type: "draw"})

      assert Basketball5x5.team_wins_from_aggregated_team_head_to_head_stats(
               phase.id,
               nil,
               nil
             ) == 0
    end
  end

  describe "update_game_results/1" do
    test "updates home score only based on team stats" do
      {:ok, home_team_stats_log} =
        %{stats: %{"points" => 100.0}}
        |> TeamHelpers.map_team_id_and_tournament_id()
        |> TeamHelpers.map_against_team_id()
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> GameHelpers.map_game_id()
        |> TeamStatsLogs.create_team_stats_log()

      {:ok, game} =
        Games.get_game!(home_team_stats_log.game_id)
        |> GameHelpers.set_home_team_id(home_team_stats_log.team_id)
        |> elem(1)
        |> GameHelpers.set_away_team_id(home_team_stats_log.against_team_id)

      {:ok, result_game} = Basketball5x5.update_game_results(game)

      assert result_game.home_score == 100
      assert result_game.away_score == 0
    end

    test "updates away score only based on team stats" do
      {:ok, away_team_stats_log} =
        %{stats: %{"points" => 100.0}}
        |> TeamHelpers.map_team_id_and_tournament_id()
        |> TeamHelpers.map_against_team_id()
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> GameHelpers.map_game_id()
        |> TeamStatsLogs.create_team_stats_log()

      {:ok, game} =
        Games.get_game!(away_team_stats_log.game_id)
        |> GameHelpers.set_away_team_id(away_team_stats_log.team_id)
        |> elem(1)
        |> GameHelpers.set_home_team_id(away_team_stats_log.against_team_id)

      {:ok, result_game} = Basketball5x5.update_game_results(game)

      assert result_game.home_score == 0
      assert result_game.away_score == 100
    end

    test "updates home and away score based on team stats" do
      {:ok, home_team_stats_log} =
        %{stats: %{"points" => 100.0}}
        |> TeamHelpers.map_team_id_and_tournament_id()
        |> TeamHelpers.map_against_team_id()
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> GameHelpers.map_game_id()
        |> TeamStatsLogs.create_team_stats_log()

      {:ok, away_team_stats_log} =
        %{
          tournament_id: home_team_stats_log.tournament_id,
          phase_id: home_team_stats_log.phase_id,
          game_id: home_team_stats_log.game_id,
          team_id: home_team_stats_log.against_team_id,
          against_team_id: home_team_stats_log.team_id,
          stats: %{"points" => 90.0}
        }
        |> TeamStatsLogs.create_team_stats_log()

      {:ok, game} =
        Games.get_game!(home_team_stats_log.game_id)
        |> GameHelpers.set_home_team_id(home_team_stats_log.team_id)
        |> elem(1)
        |> GameHelpers.set_away_team_id(away_team_stats_log.team_id)

      {:ok, result_game} = Basketball5x5.update_game_results(game)

      assert result_game.home_score == 100
      assert result_game.away_score == 90
    end
  end

  describe "apply_sport_package/1" do
    test "applies sport package to a tournament" do
      sport = Basketball5x5.sport()
      {:ok, tournament} = TournamentHelpers.create_simple_tournament()

      {:ok, result_tournament} = Basketball5x5.apply_sport_package(tournament)

      assert result_tournament.sport_slug == "basketball_5x5"
      assert result_tournament.sport_name == "Basketball 5x5"

      Enum.each(sport.player_statistics, fn statistic ->
        player_stat = find_tournament_player_stats(result_tournament, statistic.slug)

        assert player_stat != nil
        assert player_stat.title == statistic.name
        assert player_stat.slug == statistic.slug
      end)

      Enum.each(sport.team_statistics, fn statistic ->
        team_stat = find_tournament_team_stats(result_tournament, statistic.slug)

        assert team_stat != nil
        assert team_stat.title == statistic.name
        assert team_stat.slug == statistic.slug
        assert team_stat.source == statistic.slug
      end)
    end

    test "does not add player stats if they already exist" do
      sport = Basketball5x5.sport()

      {:ok, tournament} =
        TournamentHelpers.create_simple_tournament(%{
          player_stats: [
            %{
              title: "Assists",
              slug: "assists",
              is_default_order: true
            },
            %{
              title: "Some other stat",
              slug: "some_stat",
              is_default_order: false
            }
          ]
        })

      original_assists_stat = find_tournament_player_stats(tournament, "assists")
      {:ok, result_tournament} = Basketball5x5.apply_sport_package(tournament)
      resulted_assists_stat = find_tournament_player_stats(result_tournament, "assists")

      # +1 because we added the some other stat to the tournament
      assert length(result_tournament.player_stats) == length(sport.player_statistics) + 1
      assert original_assists_stat == resulted_assists_stat
    end

    test "does not add team stats if they already exist" do
      sport = Basketball5x5.sport()

      {:ok, tournament} =
        TournamentHelpers.create_simple_tournament(%{
          team_stats: [
            %{
              title: "Points",
              slug: "points",
              source: "points"
            },
            %{
              title: "Some other stat",
              slug: "some_stat",
              source: "some_stat"
            }
          ]
        })

      original_points_stat = find_tournament_team_stats(tournament, "points")
      {:ok, result_tournament} = Basketball5x5.apply_sport_package(tournament)
      resulted_points_stat = find_tournament_team_stats(result_tournament, "points")

      # +1 because we added the some other stat to the tournament
      assert length(result_tournament.team_stats) == length(sport.team_statistics) + 1
      assert original_points_stat == resulted_points_stat
    end
  end

  def find_tournament_player_stats(tournament, stat_slug) do
    Enum.find(tournament.player_stats, fn player_stat -> player_stat.slug == stat_slug end)
  end

  def find_tournament_team_stats(tournament, stat_slug) do
    Enum.find(tournament.team_stats, fn team_stat -> team_stat.slug == stat_slug end)
  end
end
