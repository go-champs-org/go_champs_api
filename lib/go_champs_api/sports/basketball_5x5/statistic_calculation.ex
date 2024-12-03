defmodule GoChampsApi.Sports.Basketball5x5.StatisticCalculation do
  def calculate_rebounds_per_game(stats) do
    stats["rebounds"] / stats["game_played"]
  end
end
