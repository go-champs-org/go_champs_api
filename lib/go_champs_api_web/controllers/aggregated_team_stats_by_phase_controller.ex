defmodule GoChampsApiWeb.AggregatedTeamStatsByPhaseController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.AggregatedTeamStatsByPhases

  action_fallback GoChampsApiWeb.FallbackController

  def index(conn, _params) do
    aggregated_team_stats_by_phase =
      AggregatedTeamStatsByPhases.list_aggregated_team_stats_by_phase()

    render(conn, "index.json", aggregated_team_stats_by_phase: aggregated_team_stats_by_phase)
  end

  def show(conn, %{"id" => id}) do
    aggregated_team_stats_by_phase =
      AggregatedTeamStatsByPhases.get_aggregated_team_stats_by_phase!(id)

    render(conn, "show.json", aggregated_team_stats_by_phase: aggregated_team_stats_by_phase)
  end
end
