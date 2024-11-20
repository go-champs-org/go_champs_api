defmodule GoChampsApi.Sports.Registry do
  alias GoChampsApi.Sports.Basketball5x5.Basketball5x5

  @sports [
    Basketball5x5.sport()
  ]

  @spec sports() :: [GoChampsApi.Sports.Sport.t()]
  def sports(), do: @sports

  @spec get_sport(String.t()) :: GoChampsApi.Sports.Sport.t()
  def get_sport(slug) do
    case Enum.find(@sports, fn sport -> sport.slug == slug end) do
      nil -> raise "Sport not found"
      sport -> sport
    end
  end
end
