defmodule GoChampsApi.Repo.Migrations.DropPendingAggregatedPlayerStatsByTournament do
  use Ecto.Migration

  def change do
    drop table(:pending_aggregated_player_stats_by_tournament)
  end
end
