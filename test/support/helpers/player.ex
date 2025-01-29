defmodule GoChampsApi.Helpers.PlayerHelpers do
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Players

  def map_player_id(tournament_id, attrs \\ %{}) do
    {:ok, player} =
      %{name: "some player", tournament_id: tournament_id}
      |> Players.create_player()

    Map.merge(attrs, %{player_id: player.id, tournament_id: player.tournament_id})
  end

  def map_player_id_and_tournament_id(attrs \\ %{}) do
    {:ok, player} =
      %{name: "some player"}
      |> TournamentHelpers.map_tournament_id()
      |> Players.create_player()

    Map.merge(attrs, %{player_id: player.id, tournament_id: player.tournament_id})
  end

  def map_player_id_and_tournament_id_with_other_member(attrs \\ %{}) do
    {:ok, player} =
      %{name: "some player"}
      |> TournamentHelpers.map_tournament_id_with_other_member()
      |> Players.create_player()

    Map.merge(attrs, %{player_id: player.id, tournament_id: player.tournament_id})
  end

  def create_player_for_tournament(tournament_id, attrs \\ %{}) do
    %{name: "some player", tournament_id: tournament_id}
    |> Map.merge(attrs)
    |> Players.create_player()
  end
end
