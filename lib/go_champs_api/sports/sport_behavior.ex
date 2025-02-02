defmodule GoChampsApi.Sports.SportBehavior do
  alias GoChampsApi.Games.Game
  alias GoChampsApi.Sports.Sport

  @callback sport() :: Sport.t()
  @callback update_game_results(%Game{}) :: {:ok, %Game{}} | {:error, any()}
end
