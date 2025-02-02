defmodule GoChampsApi.Infrastructure.Jobs.GenerateAggregatedTeamStats do
  use Oban.Worker, queue: :generate_aggregated_team_stats

  alias GoChampsApi.AggregatedTeamStatsByPhases

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"phase_id" => phase_id}}) do
    case phase_id do
      nil ->
        :error

      _ ->
        phase_id
        |> AggregatedTeamStatsByPhases.generate_aggregated_team_stats_for_phase()

        {:ok, "Aggregated team stats generated for phase #{phase_id}"}
    end
  end
end
