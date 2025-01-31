defmodule GoChampsApi.Helpers.PlayerHelpers do
  alias GoChampsApi.Helpers.GameHelpers
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Players

  def map_player_id_in_attrs(attrs \\ %{}) do
    {:ok, player} =
      %{name: "some player"}
      |> create_or_use_tournament_id(attrs)
      |> Players.create_player()

    Map.merge(attrs, %{player_id: player.id})
  end

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

    attrs
    |> Map.merge(%{player_id: player.id, tournament_id: player.tournament_id})
  end

  def map_player_id_and_tournament_id_with_other_member(attrs \\ %{}) do
    {:ok, player} =
      %{name: "some player"}
      |> TournamentHelpers.map_tournament_id_with_other_member()
      |> Players.create_player()

    Map.merge(attrs, %{player_id: player.id, tournament_id: player.tournament_id})
  end

  def map_player_id_and_tournament_id_and_game_id(attrs \\ %{}) do
    {:ok, player} =
      %{name: "some player"}
      |> TournamentHelpers.map_tournament_id()
      |> Players.create_player()

    attrs
    |> Map.merge(%{player_id: player.id, tournament_id: player.tournament_id})
    |> GameHelpers.map_game_id()
  end

  def create_player_for_tournament(tournament_id, attrs \\ %{}) do
    %{name: "some player", tournament_id: tournament_id}
    |> Map.merge(attrs)
    |> Players.create_player()
  end

  defp create_or_use_tournament_id(player_attrs, additional_attrs) do
    case Map.fetch(additional_attrs, :tournament_id) do
      {:ok, tournament_id} ->
        Map.merge(player_attrs, %{tournament_id: tournament_id})

      :error ->
        player_attrs
        |> TournamentHelpers.map_tournament_id()
    end
  end
end
