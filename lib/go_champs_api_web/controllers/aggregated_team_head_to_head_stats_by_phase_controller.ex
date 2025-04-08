defmodule GoChampsApiWeb.AggregatedTeamHeadToHeadStatsByPhaseController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases
  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases.AggregatedTeamHeadToHeadStatsByPhase

  action_fallback GoChampsApiWeb.FallbackController

  def index(conn, _params) do
    aggregated_team_head_to_head_stats_by_phase =
      AggregatedTeamHeadToHeadStatsByPhases.list_aggregated_team_head_to_head_stats_by_phase()

    render(conn, "index.json",
      aggregated_team_head_to_head_stats_by_phase: aggregated_team_head_to_head_stats_by_phase
    )
  end

  def show(conn, %{"id" => id}) do
    aggregated_team_head_to_head_stats_by_phase =
      AggregatedTeamHeadToHeadStatsByPhases.get_aggregated_team_head_to_head_stats_by_phase!(id)

    render(conn, "show.json",
      aggregated_team_head_to_head_stats_by_phase: aggregated_team_head_to_head_stats_by_phase
    )
  end
end
