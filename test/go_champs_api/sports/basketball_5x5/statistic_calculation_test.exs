defmodule GoChampsApi.Sports.Basketball5x5.StatisticCalculationTest do
  use ExUnit.Case
  alias GoChampsApi.Sports.Basketball5x5.StatisticCalculation

  @stats [
    {"assists", :calculate_assists_per_game},
    {"blocks", :calculate_blocks_per_game},
    {"disqualifications", :calculate_disqualifications_per_game},
    {"ejections", :calculate_ejections_per_game},
    {"field_goals_made", :calculate_field_goals_made_per_game},
    {"field_goals_attempted", :calculate_field_goals_attempted_per_game},
    {"field_goals_missed", :calculate_field_goals_missed_per_game},
    {"fouls", :calculate_fouls_per_game},
    {"fouls_flagrant", :calculate_fouls_flagrant_per_game},
    {"fould_personal", :calculate_fouls_personal_per_game},
    {"fouls_technical", :calculate_fouls_technical_per_game},
    {"free_throws_made", :calculate_free_throws_made_per_game},
    {"free_throws_attempted", :calculate_free_throws_attempted_per_game},
    {"free_throws_missed", :calculate_free_throws_missed_per_game},
    {"minutes_played", :calculate_minutes_played_per_game},
    {"plus_minus", :calculate_plus_minus_per_game},
    {"points", :calculate_points_per_game},
    {"rebounds", :calculate_rebounds_per_game},
    {"rebounds_defensive", :calculate_rebounds_defensive_per_game},
    {"rebounds_offensive", :calculate_rebounds_offensive_per_game},
    {"steals", :calculate_steals_per_game},
    {"three_point_field_goals_made", :calculate_three_point_field_goals_made_per_game},
    {"three_point_field_goals_attempted", :calculate_three_point_field_goals_attempted_per_game},
    {"three_point_field_goals_missed", :calculate_three_point_field_goals_missed_per_game},
    {"turnovers", :calculate_turnovers_per_game}
  ]

  for {stat, function} <- @stats do
    describe "#{function}/1" do
      test "returns 0 when game_played is 0" do
        stats = %{unquote(stat) => 10, "game_played" => 0}
        assert apply(StatisticCalculation, unquote(function), [stats]) == 0
      end

      test "returns 0 when game_played is nil" do
        stats = %{unquote(stat) => 10}
        assert apply(StatisticCalculation, unquote(function), [stats]) == 0
      end

      test "returns 0 when #{stat} is nil" do
        stats = %{"game_played" => 10}
        assert apply(StatisticCalculation, unquote(function), [stats]) == 0
      end

      test "returns 5 when #{stat} is 10 and game_played is 2" do
        stats = %{unquote(stat) => 10, "game_played" => 2}
        assert apply(StatisticCalculation, unquote(function), [stats]) == 5
      end
    end
  end
end
