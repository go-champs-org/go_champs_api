defmodule GoChampsApi.Sports.Basketball5x5.StatisticCalculation do
  def calculate_field_goal_percentage(stats) do
    field_goals_made = stats |> retrieve_stat_value("field_goals_made")
    field_goals_missed = stats |> retrieve_stat_value("field_goals_missed")

    calculate_made_miss_percentage(field_goals_made, field_goals_missed)
  end

  def calculate_field_goals_attempted(stats) do
    field_goals_made = stats |> retrieve_stat_value("field_goals_made")
    field_goals_missed = stats |> retrieve_stat_value("field_goals_missed")

    field_goals_made + field_goals_missed
  end

  def calculate_free_throw_percentage(stats) do
    free_throws_made = stats |> retrieve_stat_value("free_throws_made")
    free_throws_missed = stats |> retrieve_stat_value("free_throws_missed")

    calculate_made_miss_percentage(free_throws_made, free_throws_missed)
  end

  def calculate_free_throws_attempted(stats) do
    free_throws_made = stats |> retrieve_stat_value("free_throws_made")
    free_throws_missed = stats |> retrieve_stat_value("free_throws_missed")

    free_throws_made + free_throws_missed
  end

  def calculate_points(stats) do
    free_throws_made = stats |> retrieve_stat_value("free_throws_made")
    field_goals_made = stats |> retrieve_stat_value("field_goals_made")
    three_point_field_goals_made = stats |> retrieve_stat_value("three_point_field_goals_made")

    free_throws_made * 1 + field_goals_made * 2 + three_point_field_goals_made * 3
  end

  def calculate_rebounds(stats) do
    rebounds_defensive = stats |> retrieve_stat_value("rebounds_defensive")
    rebounds_offensive = stats |> retrieve_stat_value("rebounds_offensive")

    rebounds_defensive + rebounds_offensive
  end

  def calculate_three_point_field_goal_percentage(stats) do
    three_point_field_goals_made = stats |> retrieve_stat_value("three_point_field_goals_made")

    three_point_field_goals_missed =
      stats |> retrieve_stat_value("three_point_field_goals_missed")

    calculate_made_miss_percentage(three_point_field_goals_made, three_point_field_goals_missed)
  end

  def calculate_three_point_field_goals_attempted(stats) do
    three_point_field_goals_made = stats |> retrieve_stat_value("three_point_field_goals_made")

    three_point_field_goals_missed =
      stats |> retrieve_stat_value("three_point_field_goals_missed")

    three_point_field_goals_made + three_point_field_goals_missed
  end

  def calculate_assists_per_game(stats) do
    stats |> calculate_stat_per_game("assists")
  end

  @spec calculate_blocks_per_game(map()) :: number()
  def calculate_blocks_per_game(stats) do
    stats |> calculate_stat_per_game("blocks")
  end

  def calculate_disqualifications_per_game(stats) do
    stats |> calculate_stat_per_game("disqualifications")
  end

  def calculate_ejections_per_game(stats) do
    stats |> calculate_stat_per_game("ejections")
  end

  def calculate_field_goal_percentage_per_game(stats) do
    field_goals_made = stats |> retrieve_stat_value("field_goals_made")
    field_goals_missed = stats |> retrieve_stat_value("field_goals_missed")

    calculate_made_miss_percentage(field_goals_made, field_goals_missed)
  end

  def calculate_field_goals_made_per_game(stats) do
    stats |> calculate_stat_per_game("field_goals_made")
  end

  def calculate_field_goals_attempted_per_game(stats) do
    stats |> calculate_stat_per_game("field_goals_attempted")
  end

  def calculate_field_goals_missed_per_game(stats) do
    stats |> calculate_stat_per_game("field_goals_missed")
  end

  def calculate_fouls_per_game(stats) do
    stats |> calculate_stat_per_game("fouls")
  end

  def calculate_fouls_flagrant_per_game(stats) do
    stats |> calculate_stat_per_game("fouls_flagrant")
  end

  def calculate_fouls_personal_per_game(stats) do
    stats |> calculate_stat_per_game("fouls_personal")
  end

  def calculate_fouls_technical_per_game(stats) do
    stats |> calculate_stat_per_game("fouls_technical")
  end

  def calculate_free_throw_percentage_per_game(stats) do
    free_throws_made = stats |> retrieve_stat_value("free_throws_made")
    free_throws_missed = stats |> retrieve_stat_value("free_throws_missed")

    calculate_made_miss_percentage(free_throws_made, free_throws_missed)
  end

  def calculate_free_throws_made_per_game(stats) do
    stats |> calculate_stat_per_game("free_throws_made")
  end

  def calculate_free_throws_attempted_per_game(stats) do
    stats |> calculate_stat_per_game("free_throws_attempted")
  end

  def calculate_free_throws_missed_per_game(stats) do
    stats |> calculate_stat_per_game("free_throws_missed")
  end

  def calculate_game_started_per_game(stats) do
    game_started = stats |> retrieve_stat_value("game_started")
    game_played = stats |> retrieve_stat_value("game_played")

    if game_played > 0 do
      game_started / game_played * 100
    else
      0
    end
  end

  def calculate_minutes_played_per_game(stats) do
    stats |> calculate_stat_per_game("minutes_played")
  end

  def calculate_plus_minus_per_game(stats) do
    stats |> calculate_stat_per_game("plus_minus")
  end

  def calculate_points_per_game(stats) do
    stats |> calculate_stat_per_game("points")
  end

  def calculate_rebounds_per_game(stats) do
    stats |> calculate_stat_per_game("rebounds")
  end

  def calculate_rebounds_defensive_per_game(stats) do
    stats |> calculate_stat_per_game("rebounds_defensive")
  end

  def calculate_rebounds_offensive_per_game(stats) do
    stats |> calculate_stat_per_game("rebounds_offensive")
  end

  def calculate_steals_per_game(stats) do
    stats |> calculate_stat_per_game("steals")
  end

  def calculate_three_point_field_goal_percentage_per_game(stats) do
    three_point_field_goals_made = stats |> retrieve_stat_value("three_point_field_goals_made")

    three_point_field_goals_missed =
      stats |> retrieve_stat_value("three_point_field_goals_missed")

    calculate_made_miss_percentage(three_point_field_goals_made, three_point_field_goals_missed)
  end

  def calculate_three_point_field_goals_made_per_game(stats) do
    stats |> calculate_stat_per_game("three_point_field_goals_made")
  end

  def calculate_three_point_field_goals_attempted_per_game(stats) do
    stats |> calculate_stat_per_game("three_point_field_goals_attempted")
  end

  def calculate_three_point_field_goals_missed_per_game(stats) do
    stats |> calculate_stat_per_game("three_point_field_goals_missed")
  end

  def calculate_turnovers_per_game(stats) do
    stats |> calculate_stat_per_game("turnovers")
  end

  def calculate_made_miss_percentage(made, missed) do
    made = made || 0
    missed = missed || 0

    if made == 0 and missed == 0 do
      0
    else
      (made / (made + missed) * 100) |> Float.round(3)
    end
  end

  def retrieve_stat_value(stats, stat_slug) do
    stat_value =
      stats
      |> Map.get(stat_slug, 0.0)

    if is_float(stat_value) do
      stat_value
    else
      {float_value, _} =
        stat_value
        # Remove non digit and non decimal point characters
        |> String.replace(~r/[^\d.]/, "")
        |> String.trim()
        |> Float.parse()

      float_value
    end
  end

  defp calculate_stat_per_game(stats, stat_slug) do
    stat_value = stats |> retrieve_stat_value(stat_slug)
    game_played = stats |> retrieve_stat_value("game_played")

    if game_played > 0 do
      stat_value / game_played
    else
      0
    end
  end
end
