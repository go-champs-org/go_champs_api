defmodule GoChampsApi.Sports.SportBehavior do
  alias GoChampsApi.Games.Game
  alias GoChampsApi.Sports.Sport
  alias GoChampsApi.Tournaments.Tournament

  @callback sport() :: Sport.t()
  @callback update_game_results(%Game{}) :: {:ok, %Game{}} | {:error, any()}
  @callback apply_sport_package(%Tournament{}) ::
              {:ok, %Tournament{}} | {:error, Ecto.Changeset.t()}
end
