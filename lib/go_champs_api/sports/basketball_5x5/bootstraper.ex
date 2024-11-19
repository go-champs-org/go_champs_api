defmodule GoChampsApi.Sports.Basketball5x5.Bootstraper do
  alias GoChampsApi.Sports.Sport
  alias GoChampsApi.Sports.Statistic

  @player_log_statistics [
    Statistic.new("assists", "Assists"),
    Statistic.new("blocks", "Blocks"),
    Statistic.new("disqualifications", "Disqualifications"),
    Statistic.new("ejections", "Ejections"),
    Statistic.new("efficiency", "Efficiency"),
    Statistic.new("field_goal_percentage", "Field Goal Percentage"),
    Statistic.new("field_goals_attempted", "Field Goals Attempted"),
    Statistic.new("field_goals_made", "Field Goals Made"),
    Statistic.new("field_goals_missed", "Field Goals Missed"),
    Statistic.new("fouls", "Fouls"),
    Statistic.new("fouls_flagrant", "Flagrant Fouls"),
    Statistic.new("fouls_personal", "Personal Fouls"),
    Statistic.new("fouls_technical", "Technical Fouls"),
    Statistic.new("free_throw_percentage", "Free Throw Percentage"),
    Statistic.new("free_throws_attempted", "Free Throws Attempted"),
    Statistic.new("free_throws_made", "Free Throws Made"),
    Statistic.new("free_throws_missed", "Free Throws Missed"),
    Statistic.new("game_played", "Game Played"),
    Statistic.new("game_started", "Game Started"),
    Statistic.new("minutes_played", "Minutes Played"),
    Statistic.new("plus_minus", "Plus Minus"),
    Statistic.new("points", "Points"),
    Statistic.new("rebounds", "Rebounds"),
    Statistic.new("rebounds_defensive", "Defensive Rebounds"),
    Statistic.new("rebounds_offensive", "Offensive Rebounds"),
    Statistic.new("steals", "Steals"),
    Statistic.new("three_point_field_goal_percentage", "Three Point Field Goal Percentage"),
    Statistic.new("three_point_field_goals_attempted", "Three Point Field Goals Attempted"),
    Statistic.new("three_point_field_goals_made", "Three Point Field Goals Made"),
    Statistic.new("three_point_field_goals_missed", "Three Point Field Goals Missed"),
    Statistic.new("turnovers", "Turnovers")
  ]

  @player_tournament_statistics [
  ]

  @team_log_statistics [
  ]

  @team_tournament_statistics [
  ]

  @sport Sport.new(
           "basketball-5x5",
           "Basketball 5x5"
         )

  @spec bootstrap() :: Sport.t()
  def bootstrap(), do: sport
end
