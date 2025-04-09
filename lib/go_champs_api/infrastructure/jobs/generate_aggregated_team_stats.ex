defmodule GoChampsApi.Infrastructure.Jobs.GenerateAggregatedTeamStats do
  use Oban.Worker, queue: :generate_aggregated_team_stats

  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"phase_id" => phase_id}}) do
    case phase_id do
      nil ->
        :error

      _ ->
        phase_id
        |> AggregatedTeamStatsByPhases.delete_aggregated_team_stats_by_phase_id()

        phase_id
        |> AggregatedTeamHeadToHeadStatsByPhases.delete_aggregated_team_head_to_head_stats_by_phase_id()

        phase_id
        |> AggregatedTeamStatsByPhases.generate_aggregated_team_stats_for_phase()

        phase_id
        |> AggregatedTeamHeadToHeadStatsByPhases.generate_aggregated_team_head_to_head_stats_by_phase()

        {:ok, "Aggregated team stats generated for phase #{phase_id}"}
    end
  end
end
