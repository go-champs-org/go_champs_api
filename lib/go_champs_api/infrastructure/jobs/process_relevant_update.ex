defmodule GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate do
  use Oban.Worker, queue: :process_relevant_update

  alias GoChampsApi.Tournaments

  @impl true
  def perform(%Oban.Job{args: %{"tournament_id" => tournament_id}}) do
    case Tournaments.set_last_relevant_update_at!(tournament_id) do
      {:ok, _} -> :ok
      {:error, _} -> {:error, "Failed to update last relevant update at"}
    end
  end
end
