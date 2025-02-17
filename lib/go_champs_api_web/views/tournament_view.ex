defmodule GoChampsApiWeb.TournamentView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.OrganizationView
  alias GoChampsApiWeb.TournamentView
  alias GoChampsApiWeb.PhaseView
  alias GoChampsApiWeb.PlayerView
  alias GoChampsApiWeb.TeamView

  def render("index.json", %{tournaments: tournaments}) do
    %{data: render_many(tournaments, TournamentView, "tournament.json")}
  end

  def render("show.json", %{tournament: tournament}) do
    %{
      data: %{
        id: tournament.id,
        name: tournament.name,
        slug: tournament.slug,
        facebook: tournament.facebook,
        instagram: tournament.instagram,
        site_url: tournament.site_url,
        twitter: tournament.twitter,
        has_aggregated_player_stats: tournament.has_aggregated_player_stats,
        sport_slug: tournament.sport_slug,
        sport_name: tournament.sport_name,
        visibility: tournament.visibility,
        organization: render_one(tournament.organization, OrganizationView, "organization.json"),
        phases: render_many(tournament.phases, PhaseView, "phase.json"),
        players: render_many(tournament.players, PlayerView, "player.json"),
        player_stats: render_many(tournament.player_stats, TournamentView, "player_stats.json"),
        teams: render_many(tournament.teams, TeamView, "team.json"),
        team_stats: render_many(tournament.team_stats, TournamentView, "team_stats.json")
      }
    }
  end

  def render("tournament.json", %{tournament: tournament}) do
    %{
      id: tournament.id,
      name: tournament.name,
      slug: tournament.slug
    }
  end

  def render("player_stats.json", %{tournament: player_stats}) do
    %{
      id: player_stats.id,
      slug: player_stats.slug,
      title: player_stats.title,
      is_default_order: player_stats.is_default_order
    }
  end

  def render("team_stats.json", %{tournament: team_stats}) do
    %{
      id: team_stats.id,
      title: team_stats.title,
      slug: team_stats.slug,
      source: team_stats.source,
      is_default_order: team_stats.is_default_order
    }
  end
end
