defmodule GoChampsApi.Infrastructure.Jobs.AfterTournamentCreation do
  use Oban.Worker, queue: :after_tournament_creation

  alias GoChampsApi.Tournaments

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"tournament_id" => tournament_id}}) do
    case tournament_id do
      nil ->
        {:error, "Tournament ID is required"}

      tournament_id ->
        Tournaments.apply_sport_package(tournament_id)
    end
  end
end
