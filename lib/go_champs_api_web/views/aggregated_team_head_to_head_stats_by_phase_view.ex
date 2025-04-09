defmodule GoChampsApiWeb.AggregatedTeamHeadToHeadStatsByPhaseView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.AggregatedTeamHeadToHeadStatsByPhaseView

  def render("index.json", %{
        aggregated_team_head_to_head_stats_by_phase: aggregated_team_head_to_head_stats_by_phase
      }) do
    %{
      data:
        render_many(
          aggregated_team_head_to_head_stats_by_phase,
          AggregatedTeamHeadToHeadStatsByPhaseView,
          "aggregated_team_head_to_head_stats_by_phase.json"
        )
    }
  end

  def render("show.json", %{
        aggregated_team_head_to_head_stats_by_phase: aggregated_team_head_to_head_stats_by_phase
      }) do
    %{
      data:
        render_one(
          aggregated_team_head_to_head_stats_by_phase,
          AggregatedTeamHeadToHeadStatsByPhaseView,
          "aggregated_team_head_to_head_stats_by_phase.json"
        )
    }
  end

  def render("aggregated_team_head_to_head_stats_by_phase.json", %{
        aggregated_team_head_to_head_stats_by_phase: aggregated_team_head_to_head_stats_by_phase
      }) do
    %{
      id: aggregated_team_head_to_head_stats_by_phase.id,
      team_id: aggregated_team_head_to_head_stats_by_phase.team_id,
      against_team_id: aggregated_team_head_to_head_stats_by_phase.against_team_id,
      tournament_id: aggregated_team_head_to_head_stats_by_phase.tournament_id,
      phase_id: aggregated_team_head_to_head_stats_by_phase.phase_id,
      stats: aggregated_team_head_to_head_stats_by_phase.stats
    }
  end
end
