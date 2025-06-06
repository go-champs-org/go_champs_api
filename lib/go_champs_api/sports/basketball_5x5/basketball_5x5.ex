defmodule GoChampsApi.Sports.Basketball5x5.Basketball5x5 do
  @behaviour GoChampsApi.Sports.SportBehavior

  alias GoChampsApi.Draws
  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases
  alias GoChampsApi.Draws
  alias GoChampsApi.Draws.Draw
  alias GoChampsApi.Games
  alias GoChampsApi.Games.Game
  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Sports.Coach
  alias GoChampsApi.Sports.Sport
  alias GoChampsApi.Sports.Statistic
  alias GoChampsApi.Sports.Basketball5x5.StatisticCalculation

  @default_player_statistic_to_order_by Statistic.new(
                                          "points",
                                          "Points",
                                          :calculated,
                                          :game,
                                          :aggregate,
                                          &StatisticCalculation.calculate_points/1
                                        )

  @player_log_statistics [
    Statistic.new("assists", "Assists", :manual, :game, :aggregate),
    Statistic.new("blocks", "Blocks", :manual, :game, :aggregate),
    Statistic.new("disqualifications", "Disqualifications", :manual, :game, :aggregate),
    Statistic.new("ejections", "Ejections", :manual, :game, :aggregate),
    Statistic.new(
      "efficiency",
      "Efficiency",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_efficiency/1
    ),
    Statistic.new(
      "field_goal_percentage",
      "Field Goal Percentage",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_field_goal_percentage/1
    ),
    Statistic.new(
      "field_goals_attempted",
      "Field Goals Attempted",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_field_goals_attempted/1
    ),
    Statistic.new("field_goals_made", "Field Goals Made", :manual, :game, :aggregate),
    Statistic.new("field_goals_missed", "Field Goals Missed", :manual, :game, :aggregate),
    Statistic.new("fouls", "Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_flagrant", "Flagrant Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_personal", "Personal Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_technical", "Technical Fouls", :manual, :game, :aggregate),
    Statistic.new(
      "free_throw_percentage",
      "Free Throw Percentage",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_free_throw_percentage/1
    ),
    Statistic.new(
      "free_throws_attempted",
      "Free Throws Attempted",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_free_throws_attempted/1
    ),
    Statistic.new("free_throws_made", "Free Throws Made", :manual, :game, :aggregate),
    Statistic.new("free_throws_missed", "Free Throws Missed", :manual, :game, :aggregate),
    Statistic.new("game_played", "Game Played", :manual, :game, :aggregate),
    Statistic.new("game_started", "Game Started", :manual, :game, :aggregate),
    Statistic.new("minutes_played", "Minutes Played", :manual, :game, :aggregate),
    Statistic.new("plus_minus", "Plus Minus", :manual, :game, :aggregate),
    @default_player_statistic_to_order_by,
    Statistic.new(
      "rebounds",
      "Rebounds",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_rebounds/1
    ),
    Statistic.new("rebounds_defensive", "Defensive Rebounds", :manual, :game, :aggregate),
    Statistic.new("rebounds_offensive", "Offensive Rebounds", :manual, :game, :aggregate),
    Statistic.new("steals", "Steals", :manual, :game, :aggregate),
    Statistic.new(
      "three_point_field_goal_percentage",
      "Three Point Field Goal Percentage",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_three_point_field_goal_percentage/1
    ),
    Statistic.new(
      "three_point_field_goals_attempted",
      "Three Point Field Goals Attempted",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_three_point_field_goals_attempted/1
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

  @team_log_statistics [
    Statistic.new("assists", "Assists", :manual, :game, :aggregate),
    Statistic.new("blocks", "Blocks", :manual, :game, :aggregate),
    Statistic.new("disqualifications", "Disqualifications", :manual, :game, :aggregate),
    Statistic.new("ejections", "Ejections", :manual, :game, :aggregate),
    Statistic.new("efficiency", "Efficiency", :manual, :game, :aggregate),
    Statistic.new(
      "field_goal_percentage",
      "Field Goal Percentage",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_field_goal_percentage/1
    ),
    Statistic.new(
      "field_goals_attempted",
      "Field Goals Attempted",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_field_goals_attempted/1
    ),
    Statistic.new("field_goals_made", "Field Goals Made", :manual, :game, :aggregate),
    Statistic.new("field_goals_missed", "Field Goals Missed", :manual, :game, :aggregate),
    Statistic.new("fouls", "Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_flagrant", "Flagrant Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_personal", "Personal Fouls", :manual, :game, :aggregate),
    Statistic.new("fouls_technical", "Technical Fouls", :manual, :game, :aggregate),
    Statistic.new(
      "free_throw_percentage",
      "Free Throw Percentage",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_free_throw_percentage/1
    ),
    Statistic.new(
      "free_throws_attempted",
      "Free Throws Attempted",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_free_throws_attempted/1
    ),
    Statistic.new("free_throws_made", "Free Throws Made", :manual, :game, :aggregate),
    Statistic.new("free_throws_missed", "Free Throws Missed", :manual, :game, :aggregate),
    Statistic.new(
      "game_played",
      "Game Played",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_team_game_played/1
    ),
    Statistic.new("points", "Points", :manual, :game, :aggregate),
    Statistic.new("rebounds", "Rebounds", :manual, :game, :aggregate),
    Statistic.new("rebounds_defensive", "Defensive Rebounds", :manual, :game, :aggregate),
    Statistic.new("rebounds_offensive", "Offensive Rebounds", :manual, :game, :aggregate),
    Statistic.new("steals", "Steals", :manual, :game, :aggregate),
    Statistic.new(
      "three_point_field_goal_percentage",
      "Three Point Field Goal Percentage",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_three_point_field_goal_percentage/1
    ),
    Statistic.new(
      "three_point_field_goals_attempted",
      "Three Point Field Goals Attempted",
      :calculated,
      :game,
      :aggregate,
      &StatisticCalculation.calculate_three_point_field_goals_attempted/1
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

  @team_log_against_team_statistics [
    Statistic.new(
      "fiba_group_points",
      "FIBA Group Points",
      :calculated,
      :game_against_team,
      :aggregate,
      &StatisticCalculation.calculate_fiba_group_points/2
    ),
    Statistic.new(
      "wins",
      "Wins",
      :calculated,
      :game_against_team,
      :aggregate,
      &StatisticCalculation.calculate_wins/2
    ),
    Statistic.new(
      "losses",
      "Losses",
      :calculated,
      :game_against_team,
      :aggregate,
      &StatisticCalculation.calculate_losses/2
    ),
    Statistic.new(
      "points_against",
      "Points Against",
      :calculated,
      :game_against_team,
      :aggregate,
      &StatisticCalculation.calculate_points_against/2
    ),
    Statistic.new(
      "points_balance",
      "Points Balance",
      :calculated,
      :game_against_team,
      :aggregate,
      &StatisticCalculation.calculate_points_balance/2
    )
  ]

  @sport Sport.new(
           "basketball_5x5",
           "Basketball 5x5",
           @player_log_statistics ++ @calculated_player_statistics,
           @team_log_statistics ++ @team_log_against_team_statistics,
           @default_player_statistic_to_order_by,
           [Coach.new(:head_coach), Coach.new(:assistant_coach)]
         )

  @impl true
  @spec sport() :: Sport.t()
  def sport(), do: @sport

  @impl true
  @spec update_game_results(%Game{}) :: {:ok, %Game{}} | {:error, any()}
  def update_game_results(%Game{} = game) do
    home_score = team_score_from_team_stats_log(game.home_team_id, game.id)
    away_score = team_score_from_team_stats_log(game.away_team_id, game.id)

    game
    |> Games.update_game(%{home_score: home_score, away_score: away_score})
  end

  @impl true
  @spec update_draw_results(%Draw{}) :: {:ok, %Draw{}} | {:error, any()}
  def update_draw_results(%Draw{} = draw) do
    updated_matches =
      Enum.map(draw.matches, fn match ->
        first_team_score =
          team_wins_from_aggregated_team_head_to_head_stats(
            draw.phase_id,
            match.first_team_id,
            match.second_team_id
          )
          |> Integer.to_string()

        second_team_score =
          team_wins_from_aggregated_team_head_to_head_stats(
            draw.phase_id,
            match.second_team_id,
            match.first_team_id
          )
          |> Integer.to_string()

        match
        |> Map.put(:first_team_score, first_team_score)
        |> Map.put(:second_team_score, second_team_score)
        |> Map.from_struct()
      end)

    Draws.update_draw(draw, %{
      matches: updated_matches
    })
  end

  def team_wins_from_aggregated_team_head_to_head_stats(_phase_id, nil, _against_team_id), do: 0
  def team_wins_from_aggregated_team_head_to_head_stats(_phase_id, _team_id, nil), do: 0
  def team_wins_from_aggregated_team_head_to_head_stats(_phase_id, nil, nil), do: 0

  def team_wins_from_aggregated_team_head_to_head_stats(phase_id, team_id, against_team_id) do
    case AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase(
           phase_id: phase_id,
           team_id: team_id,
           against_team_id: against_team_id
         ) do
      [team_stats] ->
        team_stats.stats["wins"]

      _ ->
        0
    end
  end

  @impl true
  @spec apply_sport_package(%Tournament{}) :: {:ok, %Tournament{}} | {:error, any()}
  def apply_sport_package(tournament) do
    player_stats =
      Enum.map(@sport.player_statistics, fn statistic ->
        build_player_stat(
          statistic,
          Tournaments.get_player_stat_by_slug!(tournament, statistic.slug)
        )
      end)

    other_player_stats =
      tournament.player_stats
      |> Enum.reject(fn stat ->
        Enum.any?(@sport.player_statistics, fn s -> s.slug == stat.slug end)
      end)
      |> Enum.map(&build_player_stat(&1, &1))

    team_stats =
      Enum.map(@sport.team_statistics, fn statistic ->
        build_team_stat(
          statistic,
          Tournaments.get_team_stat_by_slug!(tournament, statistic.slug)
        )
      end)

    other_team_stats =
      tournament.team_stats
      |> Enum.reject(fn stat ->
        Enum.any?(@sport.team_statistics, fn s -> s.slug == stat.slug end)
      end)
      |> Enum.map(&build_team_stat(&1, &1))

    Tournaments.update_tournament(tournament, %{
      sport_slug: @sport.slug,
      sport_name: @sport.name,
      player_stats: player_stats ++ other_player_stats,
      team_stats: team_stats ++ other_team_stats
    })
  end

  defp team_score_from_team_stats_log(team_id, game_id) do
    case TeamStatsLogs.list_team_stats_log(team_id: team_id, game_id: game_id) do
      [team_stats] ->
        team_stats
        |> points_from_team_stats_log()
        |> trunc()

      _ ->
        0
    end
  end

  defp points_from_team_stats_log(team_stats) do
    team_stats.stats["points"]
  end

  defp build_player_stat(statistic, player_stat) do
    case player_stat do
      nil ->
        %{
          slug: statistic.slug,
          title: statistic.name
        }

      player_stat ->
        %{
          id: player_stat.id,
          slug: player_stat.slug,
          title: player_stat.title,
          is_default_order: player_stat.is_default_order
        }
    end
  end

  defp build_team_stat(statistic, team_stat) do
    case team_stat do
      nil ->
        %{
          slug: statistic.slug,
          title: statistic.name,
          source: statistic.slug
        }

      team_stat ->
        %{
          id: team_stat.id,
          slug: team_stat.slug,
          title: team_stat.title,
          source: team_stat.source
        }
    end
  end
end
