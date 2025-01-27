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
    {"fouls_personal", :calculate_fouls_personal_per_game},
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
        stats = %{unquote(stat) => "10", "game_played" => "0"}
        assert apply(StatisticCalculation, unquote(function), [stats]) == 0
      end

      test "returns 0 when game_played is nil" do
        stats = %{unquote(stat) => "10"}
        assert apply(StatisticCalculation, unquote(function), [stats]) == 0
      end

      test "returns 0 when #{stat} is nil" do
        stats = %{"game_played" => "10"}
        assert apply(StatisticCalculation, unquote(function), [stats]) == 0
      end

      test "returns 5 when #{stat} is 10 and game_played is 2" do
        stats = %{unquote(stat) => "10", "game_played" => "2"}
        assert apply(StatisticCalculation, unquote(function), [stats]) == 5
      end
    end
  end

  describe "calculate_field_goal_percentage_per_game/1" do
    test "returns 100 when field_goals_missed is 0" do
      stats = %{"field_goals_made" => "10", "field_goals_missed" => "0"}
      assert StatisticCalculation.calculate_field_goal_percentage_per_game(stats) == 100
    end

    test "returns 100 when field_goals_missed is nil" do
      stats = %{"field_goals_made" => "10"}
      assert StatisticCalculation.calculate_field_goal_percentage_per_game(stats) == 100
    end

    test "returns 0 when field_goals_made is nil" do
      stats = %{"field_goals_missed" => "10"}
      assert StatisticCalculation.calculate_field_goal_percentage_per_game(stats) == 0
    end

    test "returns 66.67 when field_goals_made is 3 and field_goals_missed is 5" do
      stats = %{"field_goals_made" => "3", "field_goals_missed" => "5"}
      assert StatisticCalculation.calculate_field_goal_percentage_per_game(stats) == 37.5
    end
  end

  describe "calculate_free_throw_percentage_per_game/1" do
    test "returns 100 when free_throws_missed is 0" do
      stats = %{"free_throws_made" => "10", "free_throws_missed" => "0"}
      assert StatisticCalculation.calculate_free_throw_percentage_per_game(stats) == 100
    end

    test "returns 100 when free_throws_missed is nil" do
      stats = %{"free_throws_made" => "10"}
      assert StatisticCalculation.calculate_free_throw_percentage_per_game(stats) == 100
    end

    test "returns 0 when free_throws_made is nil" do
      stats = %{"free_throws_missed" => "10"}
      assert StatisticCalculation.calculate_free_throw_percentage_per_game(stats) == 0
    end

    test "returns 66.67 when free_throws_made is 3 and free_throws_missed is 5" do
      stats = %{"free_throws_made" => "3", "free_throws_missed" => "5"}
      assert StatisticCalculation.calculate_free_throw_percentage_per_game(stats) == 37.5
    end
  end

  describe "calculate_game_started_per_game/1" do
    test "returns 0 when game_played is 0" do
      stats = %{"game_started" => "10", "game_played" => "0"}
      assert StatisticCalculation.calculate_game_started_per_game(stats) == 0
    end

    test "returns 0 when game_played is nil" do
      stats = %{"game_started" => "10"}
      assert StatisticCalculation.calculate_game_started_per_game(stats) == 0
    end

    test "returns 0 when game_started is nil" do
      stats = %{"game_played" => "10"}
      assert StatisticCalculation.calculate_game_started_per_game(stats) == 0
    end

    test "returns 5 when game_started is 5 and game_played is 8" do
      stats = %{"game_started" => "5", "game_played" => "8"}
      assert StatisticCalculation.calculate_game_started_per_game(stats) == 62.5
    end
  end

  describe "calculate_three_point_field_goal_percentage_per_game" do
    test "returns 100 when three_point_field_goals_missed is 0" do
      stats = %{
        "three_point_field_goals_made" => "10",
        "three_point_field_goals_missed" => "0"
      }

      assert StatisticCalculation.calculate_three_point_field_goal_percentage_per_game(stats) ==
               100
    end

    test "returns 100 when three_point_field_goals_missed is nil" do
      stats = %{"three_point_field_goals_made" => "10"}

      assert StatisticCalculation.calculate_three_point_field_goal_percentage_per_game(stats) ==
               100
    end

    test "returns 0 when three_point_field_goals_made is nil" do
      stats = %{"three_point_field_goals_missed" => "10"}
      assert StatisticCalculation.calculate_three_point_field_goal_percentage_per_game(stats) == 0
    end

    test "returns 66.67 when three_point_field_goals_made is 3 and three_point_field_goals_missed is 5" do
      stats = %{
        "three_point_field_goals_made" => "3",
        "three_point_field_goals_missed" => "5"
      }

      assert StatisticCalculation.calculate_three_point_field_goal_percentage_per_game(stats) ==
               37.5
    end
  end

  describe "calculate_field_goal_percentage/1" do
    test "returns 100 when field_goals_missed is 0" do
      stats = %{"field_goals_made" => "10", "field_goals_missed" => "0"}
      assert StatisticCalculation.calculate_field_goal_percentage(stats) == 100
    end

    test "returns 100 when field_goals_missed is nil" do
      stats = %{"field_goals_made" => "10"}
      assert StatisticCalculation.calculate_field_goal_percentage(stats) == 100
    end

    test "returns 0 when field_goals_made is nil" do
      stats = %{"field_goals_missed" => "10"}
      assert StatisticCalculation.calculate_field_goal_percentage(stats) == 0
    end

    test "returns 66.67 when field_goals_made is 3 and field_goals_missed is 5" do
      stats = %{"field_goals_made" => "3", "field_goals_missed" => "5"}
      assert StatisticCalculation.calculate_field_goal_percentage(stats) == 37.5
    end
  end

  describe "calculate_field_goals_attempted/1" do
    test "returns 0 when field_goals_made and field_goals_missed are nil" do
      stats = %{}
      assert StatisticCalculation.calculate_field_goals_attempted(stats) == 0
    end

    test "returns 10 when field_goals_missed is nil" do
      stats = %{"field_goals_made" => "10"}
      assert StatisticCalculation.calculate_field_goals_attempted(stats) == 10
    end

    test "returns 10 when field_goals_made is nil" do
      stats = %{"field_goals_missed" => "10"}
      assert StatisticCalculation.calculate_field_goals_attempted(stats) == 10
    end

    test "returns 20 when field_goals_made is 10 and field_goals_missed is 10" do
      stats = %{"field_goals_made" => "10", "field_goals_missed" => "10"}
      assert StatisticCalculation.calculate_field_goals_attempted(stats) == 20
    end
  end

  describe "calculate_free_throw_percentage/1" do
    test "returns 100 when free_throws_missed is 0" do
      stats = %{"free_throws_made" => "10", "free_throws_missed" => "0"}
      assert StatisticCalculation.calculate_free_throw_percentage(stats) == 100
    end

    test "returns 100 when free_throws_missed is nil" do
      stats = %{"free_throws_made" => "10"}
      assert StatisticCalculation.calculate_free_throw_percentage(stats) == 100
    end

    test "returns 0 when free_throws_made is nil" do
      stats = %{"free_throws_missed" => "10"}
      assert StatisticCalculation.calculate_free_throw_percentage(stats) == 0
    end

    test "returns 66.67 when free_throws_made is 3 and free_throws_missed is 5" do
      stats = %{"free_throws_made" => "3", "free_throws_missed" => "5"}
      assert StatisticCalculation.calculate_free_throw_percentage(stats) == 37.5
    end
  end

  describe "calculate_free_throws_attempted/1" do
    test "returns 0 when free_throws_made and free_throws_missed are nil" do
      stats = %{}
      assert StatisticCalculation.calculate_free_throws_attempted(stats) == 0
    end

    test "returns 10 when free_throws_missed is nil" do
      stats = %{"free_throws_made" => "10"}
      assert StatisticCalculation.calculate_free_throws_attempted(stats) == 10
    end

    test "returns 10 when free_throws_made is nil" do
      stats = %{"free_throws_missed" => "10"}
      assert StatisticCalculation.calculate_free_throws_attempted(stats) == 10
    end

    test "returns 20 when free_throws_made is 10 and free_throws_missed is 10" do
      stats = %{"free_throws_made" => "10", "free_throws_missed" => "10"}
      assert StatisticCalculation.calculate_free_throws_attempted(stats) == 20
    end
  end

  describe "calculate_points/1" do
    test "returns 0 when free_throws_made, field_goals_made and three_point_field_goals_made are nil" do
      stats = %{}
      assert StatisticCalculation.calculate_points(stats) == 0
    end

    test "returns 10 when free_throws_made is 10" do
      stats = %{"free_throws_made" => "10"}
      assert StatisticCalculation.calculate_points(stats) == 10
    end

    test "returns 10 when field_goals_made is 5" do
      stats = %{"field_goals_made" => "5"}
      assert StatisticCalculation.calculate_points(stats) == 10
    end

    test "return 9 when three_point_field_goals_made is 3" do
      stats = %{"three_point_field_goals_made" => "3"}
      assert StatisticCalculation.calculate_points(stats) == 9
    end

    test "returns 24 when free_throws_made is 4, field_goals_made is 5 and three_point_field_goals_made is 2" do
      stats = %{
        "free_throws_made" => "4",
        "field_goals_made" => "5",
        "three_point_field_goals_made" => "2"
      }

      assert StatisticCalculation.calculate_points(stats) == 20
    end
  end

  describe "calculate_rebounds/1" do
    test "returns 0 when rebounds_offensive and rebounds_defensive are nil" do
      stats = %{}
      assert StatisticCalculation.calculate_rebounds(stats) == 0
    end

    test "returns 10 when rebounds_offensive is nil" do
      stats = %{"rebounds_defensive" => "10"}
      assert StatisticCalculation.calculate_rebounds(stats) == 10
    end

    test "returns 10 when rebounds_defensive is nil" do
      stats = %{"rebounds_offensive" => "10"}
      assert StatisticCalculation.calculate_rebounds(stats) == 10
    end

    test "returns 20 when rebounds_offensive is 10 and rebounds_defensive is 10" do
      stats = %{"rebounds_offensive" => "10", "rebounds_defensive" => "10"}
      assert StatisticCalculation.calculate_rebounds(stats) == 20
    end
  end

  describe "calculate_three_point_field_goal_percentage/1" do
    test "returns 100 when three_point_field_goals_missed is 0" do
      stats = %{"three_point_field_goals_made" => "10", "three_point_field_goals_missed" => "0"}
      assert StatisticCalculation.calculate_three_point_field_goal_percentage(stats) == 100
    end

    test "returns 100 when three_point_field_goals_missed is nil" do
      stats = %{"three_point_field_goals_made" => "10"}
      assert StatisticCalculation.calculate_three_point_field_goal_percentage(stats) == 100
    end

    test "returns 0 when three_point_field_goals_made is nil" do
      stats = %{"three_point_field_goals_missed" => "10"}
      assert StatisticCalculation.calculate_three_point_field_goal_percentage(stats) == 0
    end

    test "returns 66.67 when three_point_field_goals_made is 3 and three_point_field_goals_missed is 5" do
      stats = %{"three_point_field_goals_made" => "3", "three_point_field_goals_missed" => "5"}
      assert StatisticCalculation.calculate_three_point_field_goal_percentage(stats) == 37.5
    end
  end

  describe "calculate_three_point_field_goals_attempted/1" do
    test "returns 0 when three_point_field_goals_made and three_point_field_goals_missed are nil" do
      stats = %{}
      assert StatisticCalculation.calculate_three_point_field_goals_attempted(stats) == 0
    end

    test "returns 10 when three_point_field_goals_missed is nil" do
      stats = %{"three_point_field_goals_made" => "10"}
      assert StatisticCalculation.calculate_three_point_field_goals_attempted(stats) == 10
    end

    test "returns 10 when three_point_field_goals_made is nil" do
      stats = %{"three_point_field_goals_missed" => "10"}
      assert StatisticCalculation.calculate_three_point_field_goals_attempted(stats) == 10
    end

    test "returns 20 when three_point_field_goals_made is 10 and three_point_field_goals_missed is 10" do
      stats = %{"three_point_field_goals_made" => "10", "three_point_field_goals_missed" => "10"}
      assert StatisticCalculation.calculate_three_point_field_goals_attempted(stats) == 20
    end
  end

  describe "calculate_made_miss_percentage/2" do
    test "returns 100 when made is 10 and miss is 0" do
      assert StatisticCalculation.calculate_made_miss_percentage(10, 0) == 100
    end

    test "returns 100 when miss is 0" do
      assert StatisticCalculation.calculate_made_miss_percentage(10, 0) == 100
    end

    test "returns 100 when miss is 0.0" do
      assert StatisticCalculation.calculate_made_miss_percentage(10, 0.0) == 100
    end

    test "returns 0 when made is 0" do
      assert StatisticCalculation.calculate_made_miss_percentage(0, 10) == 0
    end

    test "returns 0 when made is 0.0" do
      assert StatisticCalculation.calculate_made_miss_percentage(0.0, 10) == 0
    end

    test "returns 66.67 when made is 3 and miss is 5" do
      assert StatisticCalculation.calculate_made_miss_percentage(3, 5) == 37.5
    end

    test "returns 0 when made and miss are 0" do
      assert StatisticCalculation.calculate_made_miss_percentage(0, 0) == 0
    end

    test "returns 0.0 when made and miss are 0.0" do
      assert StatisticCalculation.calculate_made_miss_percentage(0.0, 0.0) == 0
    end

    test "returns 0 when made and miss are nil" do
      assert StatisticCalculation.calculate_made_miss_percentage(nil, nil) == 0
    end

    test "returns 100 when made is 10 and miss is nil" do
      assert StatisticCalculation.calculate_made_miss_percentage(10, nil) == 100
    end

    test "returns 0 when made is nil" do
      assert StatisticCalculation.calculate_made_miss_percentage(nil, 10) == 0
    end
  end

  describe "retrieve_stat_value/2" do
    test "returns 0 when stat is nil" do
      stats = %{}
      assert StatisticCalculation.retrieve_stat_value(stats, "field_goals_made") == 0
    end

    test "returns 10.5 when stat is '10.5'" do
      stats = %{"field_goals_made" => "10.5"}
      assert StatisticCalculation.retrieve_stat_value(stats, "field_goals_made") == 10.5
    end

    test "returns 10.5 when stat is 10.5" do
      stats = %{"field_goals_made" => 10.5}
      assert StatisticCalculation.retrieve_stat_value(stats, "field_goals_made") == 10.5
    end
  end
end
