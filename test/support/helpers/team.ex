defmodule GoChampsApi.Helpers.TeamHelpers do
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Teams

  def map_team_id_in_attrs(attrs \\ %{}) do
    {:ok, team} =
      %{name: "some team"}
      |> create_or_use_tournament_id(attrs)
      |> Teams.create_team()

    Map.merge(attrs, %{team_id: team.id})
  end

  def map_team_id(tournament_id, attrs \\ %{}) do
    {:ok, team} =
      %{name: "some team", tournament_id: tournament_id}
      |> Teams.create_team()

    Map.merge(attrs, %{team_id: team.id, tournament_id: team.tournament_id})
  end

  def map_team_id_and_tournament_id(attrs \\ %{}) do
    {:ok, team} =
      %{name: "some team"}
      |> TournamentHelpers.map_tournament_id()
      |> Teams.create_team()

    Map.merge(attrs, %{team_id: team.id, tournament_id: team.tournament_id})
  end

  def map_team_id_and_tournament_id_with_other_member(attrs \\ %{}) do
    {:ok, team} =
      %{name: "some team"}
      |> TournamentHelpers.map_tournament_id_with_other_member()
      |> Teams.create_team()

    Map.merge(attrs, %{team_id: team.id, tournament_id: team.tournament_id})
  end

  defp create_or_use_tournament_id(team_attrs, additional_attrs) do
    case Map.fetch(additional_attrs, :tournament_id) do
      {:ok, tournament_id} ->
        Map.merge(team_attrs, %{tournament_id: tournament_id})

      :error ->
        team_attrs
        |> TournamentHelpers.map_tournament_id()
    end
  end
end
