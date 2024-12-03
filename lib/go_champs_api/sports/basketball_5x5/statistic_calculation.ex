defmodule GoChampsApi.Sports.Basketball5x5.StatisticCalculation do
  def calculate_rebounds_per_game(stats) do
    rebounds = stats |> retrieve_stat_value("rebounds")
    game_played = stats |> retrieve_stat_value("game_played")

    if game_played > 0 do
      rebounds / game_played
    else
      0
    end
  end

  defp retrieve_stat_value(stats, stat_slug) do
    case Map.get(stats, stat_slug) do
      nil -> 0
      value -> value
    end
  end
end
