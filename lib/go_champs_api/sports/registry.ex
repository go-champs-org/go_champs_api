defmodule GoChampsApi.Sports.Registry do
  alias GoChampsApi.Sports.Basketball5x5.Basketball5x5

  @sports [
    Basketball5x5.sport()
  ]

  @spec sports() :: [GoChampsApi.Sports.Sport.t()]
  def sports(), do: @sports
end
