defmodule GoChampsApi.Helpers.GameHelpers do
  alias GoChampsApi.Games
  alias GoChampsApi.Helpers.PhaseHelpers

  def map_game_id(attrs \\ %{}) do
    game_attrs =
      attrs
      |> create_or_use_phase_id()

    {:ok, game} = Games.create_game(game_attrs)

    Map.merge(attrs, %{game_id: game.id})
  end

  defp create_or_use_phase_id(attrs \\ %{}) do
    case Map.fetch(attrs, :phase_id) do
      {:ok, phase_id} ->
        Map.merge(attrs, %{phase_id: phase_id})

      :error ->
        attrs
        |> PhaseHelpers.map_phase_id()
    end
  end
end
