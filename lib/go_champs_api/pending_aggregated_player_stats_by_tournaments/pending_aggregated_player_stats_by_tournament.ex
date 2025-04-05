defmodule GoChampsApi.PendingAggregatedPlayerStatsByTournaments.PendingAggregatedPlayerStatsByTournament do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset

  alias GoChampsApi.Tournaments.Tournament

  schema "pending_aggregated_player_stats_by_tournament" do
    belongs_to :tournament, Tournament

    timestamps()
  end

  @doc false
  def changeset(pending_aggregated_player_stats_by_tournament, attrs) do
    pending_aggregated_player_stats_by_tournament
    |> cast(attrs, [:tournament_id])
    |> validate_required([:tournament_id])
  end
end
