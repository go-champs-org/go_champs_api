defmodule GoChampsApi.Sports.Basketball5x5.Basketball5x5Test do
  use ExUnit.Case
  alias GoChampsApi.Sports.Basketball5x5.Basketball5x5
  alias GoChampsApi.Sports.Sport

  describe "sport/0" do
    test "returns basketball 5x5 sport" do
      sport = %Sport{
        slug: "basketball-5x5",
        name: "Basketball 5x5"
      }

      assert Basketball5x5.sport() == sport
    end
  end

  describe "all_player_statistics/0" do
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
        "game_played_per_game",
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
        Basketball5x5.all_player_statistics()
        |> Enum.map(fn statistic -> statistic.slug end)

      assert resulted_statistics_slugs == expected_statistics
    end
  end
end
