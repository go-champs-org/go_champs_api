defmodule GoChampsApiWeb.TeamStatsLogView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.TeamStatsLogView

  def render("index.json", %{team_stats_log: team_stats_log}) do
    %{data: render_many(team_stats_log, TeamStatsLogView, "team_stats_log.json")}
  end

  def render("show.json", %{team_stats_log: team_stats_log}) do
    %{data: render_one(team_stats_log, TeamStatsLogView, "team_stats_log.json")}
  end

  def render("team_stats_log.json", %{team_stats_log: team_stats_log}) do
    %{
      id: team_stats_log.id,
      game_id: team_stats_log.game_id,
      phase_id: team_stats_log.phase_id,
      team_id: team_stats_log.team_id,
      against_team_id: team_stats_log.against_team_id,
      tournament_id: team_stats_log.tournament_id,
      stats: team_stats_log.stats
    }
  end
end
