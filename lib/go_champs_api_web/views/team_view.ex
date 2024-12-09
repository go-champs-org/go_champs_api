defmodule GoChampsApiWeb.TeamView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.TeamView
  alias GoChampsApiWeb.PlayerView

  def render("index.json", %{teams: teams}) do
    %{data: render_many(teams, TeamView, "team.json")}
  end

  def render("show.json", %{team: team}) do
    %{data: render_one(team, TeamView, "team.json")}
  end

  def render("team.json", %{team: team}) do
    %{id: team.id, name: team.name, players: render_players(team.players)}
  end

  defp render_players(%Ecto.Association.NotLoaded{}), do: []
  defp render_players(players), do: render_many(players, PlayerView, "player.json")
end
