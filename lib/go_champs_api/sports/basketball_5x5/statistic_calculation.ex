defmodule GoChampsApi.Sports.Basketball5x5.StatisticCalculation do
  def calculate_rebounds(stats) do
    stats["rebounds_defensive"] + stats["rebounds_offensive"]
  end
end
