defmodule GoChampsApi.Sports.Basketball5x5.Basketball5x5 do
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

  @player_average_statistics [
    Statistic.new("assists_per_game", "Assists Per Game"),
    Statistic.new("blocks_per_game", "Blocks Per Game"),
    Statistic.new("disqualifications_per_game", "Disqualifications Per Game"),
    Statistic.new("ejections_per_game", "Ejections Per Game"),
    Statistic.new("efficiency_per_game", "Efficiency Per Game"),
    Statistic.new("field_goal_percentage_per_game", "Field Goal Percentage Per Game"),
    Statistic.new("field_goals_attempted_per_game", "Field Goals Attempted Per Game"),
    Statistic.new("field_goals_made_per_game", "Field Goals Made Per Game"),
    Statistic.new("field_goals_missed_per_game", "Field Goals Missed Per Game"),
    Statistic.new("fouls_per_game", "Fouls Per Game"),
    Statistic.new("fouls_flagrant_per_game", "Flagrant Fouls Per Game"),
    Statistic.new("fouls_personal_per_game", "Personal Fouls Per Game"),
    Statistic.new("fouls_technical_per_game", "Technical Fouls Per Game"),
    Statistic.new("free_throw_percentage_per_game", "Free Throw Percentage Per Game"),
    Statistic.new("free_throws_attempted_per_game", "Free Throws Attempted Per Game"),
    Statistic.new("free_throws_made_per_game", "Free Throws Made Per Game"),
    Statistic.new("free_throws_missed_per_game", "Free Throws Missed Per Game"),
    Statistic.new("game_played_per_game", "Game Played Per Game"),
    Statistic.new("game_started_per_game", "Game Started Per Game"),
    Statistic.new("minutes_played_per_game", "Minutes Played Per Game"),
    Statistic.new("plus_minus_per_game", "Plus Minus Per Game"),
    Statistic.new("points_per_game", "Points Per Game"),
    Statistic.new("rebounds_per_game", "Rebounds Per Game"),
    Statistic.new("rebounds_defensive_per_game", "Defensive Rebounds Per Game"),
    Statistic.new("rebounds_offensive_per_game", "Offensive Rebounds Per Game"),
    Statistic.new("steals_per_game", "Steals Per Game"),
    Statistic.new(
      "three_point_field_goal_percentage_per_game",
      "Three Point Field Goal Percentage Per Game"
    ),
    Statistic.new(
      "three_point_field_goals_attempted_per_game",
      "Three Point Field Goals Attempted Per Game"
    ),
    Statistic.new(
      "three_point_field_goals_made_per_game",
      "Three Point Field Goals Made Per Game"
    ),
    Statistic.new(
      "three_point_field_goals_missed_per_game",
      "Three Point Field Goals Missed Per Game"
    ),
    Statistic.new("turnovers_per_game", "Turnovers Per Game")
  ]

  @team_log_statistics []

  @team_tournament_statistics []

  @sport Sport.new(
           "basketball-5x5",
           "Basketball 5x5"
         )

  @spec sport() :: Sport.t()
  def sport(), do: @sport

  @spec all_player_statistics() :: [Statistic.t()]
  def all_player_statistics() do
    @player_log_statistics ++ @player_average_statistics
  end
end
