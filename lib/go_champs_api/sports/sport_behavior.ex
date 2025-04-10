defmodule GoChampsApi.Sports.SportBehavior do
  alias GoChampsApi.Games.Game
  alias GoChampsApi.Sports.Sport
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Draws.Draw

  @callback sport() :: Sport.t()
  @callback update_draw_results(%Draw{}) :: {:ok, %Draw{}} | {:error, any()}
  @callback update_game_results(%Game{}) :: {:ok, %Game{}} | {:error, any()}
  @callback apply_sport_package(%Tournament{}) ::
              {:ok, %Tournament{}} | {:error, Ecto.Changeset.t()}
end
