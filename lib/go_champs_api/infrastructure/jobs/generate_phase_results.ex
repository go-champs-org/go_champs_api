defmodule GoChampsApi.Infrastructure.Jobs.GeneratePhaseResults do
  use Oban.Worker, queue: :generate_phase_results

  alias GoChampsApi.Phases

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"phase_id" => phase_id}}) do
    case phase_id do
      nil ->
        {:error, "phase_id is required"}

      _ ->
        Phases.generate_phase_results(phase_id)
        {:ok, "Phase results has been generated for phase #{phase_id}"}
    end
  end
end
