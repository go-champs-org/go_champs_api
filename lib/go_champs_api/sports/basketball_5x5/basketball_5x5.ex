defmodule GoChampsApi.Sports.Basketball5x5.Basketball5x5 do
  alias GoChampsApi.Sports.Sport
  alias GoChampsApi.Sports.Statistic
  alias GoChampsApi.Sports.Basketball5x5.StatisticCalculation

  @player_log_statistics [
    Statistic.new("assists", "Assists", :manual, :game, :aggregate),
    Statistic.new("blocks", "Blocks", :manual, :game, :aggregate),
    Statistic.new("disqualifications", "Disqualifications", :manual, :game, :aggregate),
    Statistic.new("ejections", "Ejections", :manual, :game, :aggregate),
    Statistic.new("efficiency", "Efficiency", :manual, :game, :aggregate),
    Statistic.new("field_goal_percentage", "Field Goal Percentage", :manual, :game, :aggregate),
    Statistic.new("field_goals_attempted", "Field Goals Attempted", :manual, :game, :aggregate),
    Statistic.new("field_goals_made", "Field Goals Made", :manual, :game, :aggregate),
    Statistic.new("field_goals_missed", "Field Goals Missed", :manual, :game, :aggregate),
    Statistic.new("fouls", "Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_flagrant", "Flagrant Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_personal", "Personal Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_technical", "Technical Fouls", :manual, :game, :aggregate),
    Statistic.new("free_throw_percentage", "Free Throw Percentage", :manual, :game, :aggregate),
    Statistic.new("free_throws_attempted", "Free Throws Attempted", :manual, :game, :aggregate),
    Statistic.new("free_throws_made", "Free Throws Made", :manual, :game, :aggregate),
    Statistic.new("free_throws_missed", "Free Throws Missed", :manual, :game, :aggregate),
    Statistic.new("game_played", "Game Played", :manual, :game, :aggregate),
    Statistic.new("game_started", "Game Started", :manual, :game, :aggregate),
    Statistic.new("minutes_played", "Minutes Played", :manual, :game, :aggregate),
    Statistic.new("plus_minus", "Plus Minus", :manual, :game, :aggregate),
    Statistic.new("points", "Points", :manual, :game, :aggregate),
    Statistic.new("rebounds", "Rebounds", :manual, :game, :aggregate),
    Statistic.new("rebounds_defensive", "Defensive Rebounds", :manual, :game, :aggregate),
    Statistic.new("rebounds_offensive", "Offensive Rebounds", :manual, :game, :aggregate),
    Statistic.new("steals", "Steals", :manual, :game, :aggregate),
    Statistic.new(
      "three_point_field_goal_percentage",
      "Three Point Field Goal Percentage",
      :manual,
      :game,
      :aggregate
    ),
    Statistic.new(
      "three_point_field_goals_attempted",
      "Three Point Field Goals Attempted",
      :manual,
      :game,
      :aggregate
    ),
    Statistic.new(
      "three_point_field_goals_made",
      "Three Point Field Goals Made",
      :manual,
      :game,
      :aggregate
    ),
    Statistic.new(
      "three_point_field_goals_missed",
      "Three Point Field Goals Missed",
      :manual,
      :game,
      :aggregate
    ),
    Statistic.new("turnovers", "Turnovers", :manual, :game, :aggregate)
  ]

  @calculated_player_statistics [
    Statistic.new(
      "assists_per_game",
      "Assists Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_assists_per_game/1
    ),
    Statistic.new(
      "blocks_per_game",
      "Blocks Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_blocks_per_game/1
    ),
    Statistic.new(
      "disqualifications_per_game",
      "Disqualifications Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_disqualifications_per_game/1
    ),
    Statistic.new(
      "ejections_per_game",
      "Ejections Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_ejections_per_game/1
    ),
    Statistic.new(
      "efficiency_per_game",
      "Efficiency Per Game",
      :calculated,
      :tournament,
      :per_game
    ),
    Statistic.new(
      "field_goal_percentage_per_game",
      "Field Goal Percentage Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_field_goal_percentage_per_game/1
    ),
    Statistic.new(
      "field_goals_attempted_per_game",
      "Field Goals Attempted Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_field_goals_attempted_per_game/1
    ),
    Statistic.new(
      "field_goals_made_per_game",
      "Field Goals Made Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_field_goals_made_per_game/1
    ),
    Statistic.new(
      "field_goals_missed_per_game",
      "Field Goals Missed Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_field_goals_missed_per_game/1
    ),
    Statistic.new(
      "fouls_per_game",
      "Fouls Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_fouls_per_game/1
    ),
    Statistic.new(
      "fouls_flagrant_per_game",
      "Flagrant Fouls Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_fouls_flagrant_per_game/1
    ),
    Statistic.new(
      "fouls_personal_per_game",
      "Personal Fouls Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_fouls_personal_per_game/1
    ),
    Statistic.new(
      "fouls_technical_per_game",
      "Technical Fouls Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_fouls_technical_per_game/1
    ),
    Statistic.new(
      "free_throw_percentage_per_game",
      "Free Throw Percentage Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_free_throw_percentage_per_game/1
    ),
    Statistic.new(
      "free_throws_attempted_per_game",
      "Free Throws Attempted Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_free_throws_attempted_per_game/1
    ),
    Statistic.new(
      "free_throws_made_per_game",
      "Free Throws Made Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_free_throws_made_per_game/1
    ),
    Statistic.new(
      "free_throws_missed_per_game",
      "Free Throws Missed Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_free_throws_missed_per_game/1
    ),
    Statistic.new(
      "game_started_per_game",
      "Game Started Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_game_started_per_game/1
    ),
    Statistic.new(
      "minutes_played_per_game",
      "Minutes Played Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_minutes_played_per_game/1
    ),
    Statistic.new(
      "plus_minus_per_game",
      "Plus Minus Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_plus_minus_per_game/1
    ),
    Statistic.new(
      "points_per_game",
      "Points Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_points_per_game/1
    ),
    Statistic.new(
      "rebounds_per_game",
      "Rebounds Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_rebounds_per_game/1
    ),
    Statistic.new(
      "rebounds_defensive_per_game",
      "Defensive Rebounds Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_rebounds_defensive_per_game/1
    ),
    Statistic.new(
      "rebounds_offensive_per_game",
      "Offensive Rebounds Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_rebounds_offensive_per_game/1
    ),
    Statistic.new(
      "steals_per_game",
      "Steals Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_steals_per_game/1
    ),
    Statistic.new(
      "three_point_field_goal_percentage_per_game",
      "Three Point Field Goal Percentage Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_three_point_field_goal_percentage_per_game/1
    ),
    Statistic.new(
      "three_point_field_goals_attempted_per_game",
      "Three Point Field Goals Attempted Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_three_point_field_goals_attempted_per_game/1
    ),
    Statistic.new(
      "three_point_field_goals_made_per_game",
      "Three Point Field Goals Made Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_three_point_field_goals_made_per_game/1
    ),
    Statistic.new(
      "three_point_field_goals_missed_per_game",
      "Three Point Field Goals Missed Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_three_point_field_goals_missed_per_game/1
    ),
    Statistic.new(
      "turnovers_per_game",
      "Turnovers Per Game",
      :calculated,
      :tournament,
      :per_game,
      &StatisticCalculation.calculate_turnovers_per_game/1
    )
  ]

  @sport Sport.new(
           "basketball_5x5",
           "Basketball 5x5",
           @player_log_statistics ++ @calculated_player_statistics
         )

  @spec sport() :: Sport.t()
  def sport(), do: @sport
end
