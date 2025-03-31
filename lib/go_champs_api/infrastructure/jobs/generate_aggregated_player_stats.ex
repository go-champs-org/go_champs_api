defmodule GoChampsApi.Infrastructure.Jobs.GenerateAggregatedPlayerStats do
  use Oban.Worker, queue: :generate_aggregated_player_stats

  alias GoChampsApi.AggregatedPlayerStatsByTournaments
  alias GoChampsApi.Tournaments

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"tournament_id" => tournament_id}}) do
    case tournament_id do
      nil ->
        :error

      _ ->
        IO.inspect("Trigger aggregated player stats generation")
        IO.inspect("Tournanment: #{tournament_id}")
        IO.inspect(DateTime.to_string(DateTime.utc_now()))
        from_date = DateTime.utc_now()

        AggregatedPlayerStatsByTournaments.delete_aggregated_player_stats_for_tournament(
          tournament_id
        )

        AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
          tournament_id
        )

        Tournaments.set_aggregated_player_stats!(tournament_id)

        IO.inspect("Tournanment: #{tournament_id}")
        IO.inspect(DateTime.to_string(DateTime.utc_now()))
        to_date = DateTime.utc_now()
        IO.inspect("Finish aggregated player stats generation")
        IO.inspect("Duration: #{DateTime.diff(from_date, to_date)} seconds")

        {:ok, "Aggregated team stats generated for phase #{tournament_id}"}
    end
  end
end
