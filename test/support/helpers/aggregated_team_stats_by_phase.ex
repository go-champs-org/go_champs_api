defmodule GoChampsApi.Helpers.AggregatedTeamStatsByPhaseHelper do
  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.TeamHelpers

  def create_aggregated_team_stats_by_phase(stats \\ %{}) do
    {:ok, aggregated_team_stats_by_phase} =
      %{
        stats: stats
      }
      |> TournamentHelpers.map_tournament_id()
      |> PhaseHelpers.map_phase_id()
      |> TeamHelpers.map_team_id_in_attrs()
      |> AggregatedTeamStatsByPhases.create_aggregated_team_stats_by_phase()

    aggregated_team_stats_by_phase
  end
end
