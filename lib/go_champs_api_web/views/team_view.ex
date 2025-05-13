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
    %{
      id: team.id,
      name: team.name,
      logo_url: team.logo_url,
      tri_code: team.tri_code,
      players: render_players(team.players),
      coaches: render_many(team.coaches, TeamView, "coach.json", as: :coach)
    }
  end

  def render("coach.json", %{coach: coach}) do
    %{
      id: coach.id,
      name: coach.name,
      type: coach.type
    }
  end

  defp render_players(%Ecto.Association.NotLoaded{}), do: []
  defp render_players(players), do: render_many(players, PlayerView, "player.json")
end
