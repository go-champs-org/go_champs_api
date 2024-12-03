defmodule GoChampsApi.Sports.Basketball5x5.Basketball5x5 do
  alias GoChampsApi.Sports.Sport
  alias GoChampsApi.Sports.Statistic
  alias GoChampsApi.Sports.Basketball5x5.StatisticCalculation

  @player_log_statistics [
    Statistic.new("assists", "Assists", :logged),
    Statistic.new("blocks", "Blocks", :logged),
    Statistic.new("disqualifications", "Disqualifications", :logged),
    Statistic.new("ejections", "Ejections", :logged),
    Statistic.new("efficiency", "Efficiency", :logged),
    Statistic.new("field_goal_percentage", "Field Goal Percentage", :logged),
    Statistic.new("field_goals_attempted", "Field Goals Attempted", :logged),
    Statistic.new("field_goals_made", "Field Goals Made", :logged),
    Statistic.new("field_goals_missed", "Field Goals Missed", :logged),
    Statistic.new("fouls", "Fouls", :logged),
    Statistic.new("fouls_flagrant", "Flagrant Fouls", :logged),
    Statistic.new("fouls_personal", "Personal Fouls", :logged),
    Statistic.new("fouls_technical", "Technical Fouls", :logged),
    Statistic.new("free_throw_percentage", "Free Throw Percentage", :logged),
    Statistic.new("free_throws_attempted", "Free Throws Attempted", :logged),
    Statistic.new("free_throws_made", "Free Throws Made", :logged),
    Statistic.new("free_throws_missed", "Free Throws Missed", :logged),
    Statistic.new("game_played", "Game Played", :logged),
    Statistic.new("game_started", "Game Started", :logged),
    Statistic.new("minutes_played", "Minutes Played", :logged),
    Statistic.new("plus_minus", "Plus Minus", :logged),
    Statistic.new("points", "Points", :logged),
    Statistic.new("rebounds", "Rebounds", :logged),
    Statistic.new("rebounds_defensive", "Defensive Rebounds", :logged),
    Statistic.new("rebounds_offensive", "Offensive Rebounds", :logged),
    Statistic.new("steals", "Steals", :logged),
    Statistic.new(
      "three_point_field_goal_percentage",
      "Three Point Field Goal Percentage",
      :logged
    ),
    Statistic.new(
      "three_point_field_goals_attempted",
      "Three Point Field Goals Attempted",
      :logged
    ),
    Statistic.new("three_point_field_goals_made", "Three Point Field Goals Made", :logged),
    Statistic.new("three_point_field_goals_missed", "Three Point Field Goals Missed", :logged),
    Statistic.new("turnovers", "Turnovers", :logged)
  ]

  @calculated_player_statistics [
    Statistic.new("assists_per_game", "Assists Per Game", :calculated),
    Statistic.new("blocks_per_game", "Blocks Per Game", :calculated),
    Statistic.new("disqualifications_per_game", "Disqualifications Per Game", :calculated),
    Statistic.new("ejections_per_game", "Ejections Per Game", :calculated),
    Statistic.new("efficiency_per_game", "Efficiency Per Game", :calculated),
    Statistic.new(
      "field_goal_percentage_per_game",
      "Field Goal Percentage Per Game",
      :calculated
    ),
    Statistic.new(
      "field_goals_attempted_per_game",
      "Field Goals Attempted Per Game",
      :calculated
    ),
    Statistic.new("field_goals_made_per_game", "Field Goals Made Per Game", :calculated),
    Statistic.new("field_goals_missed_per_game", "Field Goals Missed Per Game", :calculated),
    Statistic.new("fouls_per_game", "Fouls Per Game", :calculated),
    Statistic.new("fouls_flagrant_per_game", "Flagrant Fouls Per Game", :calculated),
    Statistic.new("fouls_personal_per_game", "Personal Fouls Per Game", :calculated),
    Statistic.new("fouls_technical_per_game", "Technical Fouls Per Game", :calculated),
    Statistic.new(
      "free_throw_percentage_per_game",
      "Free Throw Percentage Per Game",
      :calculated
    ),
    Statistic.new(
      "free_throws_attempted_per_game",
      "Free Throws Attempted Per Game",
      :calculated
    ),
    Statistic.new("free_throws_made_per_game", "Free Throws Made Per Game", :calculated),
    Statistic.new("free_throws_missed_per_game", "Free Throws Missed Per Game", :calculated),
    Statistic.new("game_played_per_game", "Game Played Per Game", :calculated),
    Statistic.new("game_started_per_game", "Game Started Per Game", :calculated),
    Statistic.new("minutes_played_per_game", "Minutes Played Per Game", :calculated),
    Statistic.new("plus_minus_per_game", "Plus Minus Per Game", :calculated),
    Statistic.new("points_per_game", "Points Per Game", :calculated),
    Statistic.new(
      "rebounds_per_game",
      "Rebounds Per Game",
      :calculated,
      &StatisticCalculation.calculate_rebounds_per_game/1
    ),
    Statistic.new("rebounds_defensive_per_game", "Defensive Rebounds Per Game", :calculated),
    Statistic.new("rebounds_offensive_per_game", "Offensive Rebounds Per Game", :calculated),
    Statistic.new("steals_per_game", "Steals Per Game", :calculated),
    Statistic.new(
      "three_point_field_goal_percentage_per_game",
      "Three Point Field Goal Percentage Per Game",
      :calculated
    ),
    Statistic.new(
      "three_point_field_goals_attempted_per_game",
      "Three Point Field Goals Attempted Per Game",
      :calculated
    ),
    Statistic.new(
      "three_point_field_goals_made_per_game",
      "Three Point Field Goals Made Per Game",
      :calculated
    ),
    Statistic.new(
      "three_point_field_goals_missed_per_game",
      "Three Point Field Goals Missed Per Game",
      :calculated
    ),
    Statistic.new("turnovers_per_game", "Turnovers Per Game", :calculated)
  ]

  @sport Sport.new(
           "basketball_5x5",
           "Basketball 5x5",
           @player_log_statistics ++ @calculated_player_statistics
         )

  @spec sport() :: Sport.t()
  def sport(), do: @sport
end
