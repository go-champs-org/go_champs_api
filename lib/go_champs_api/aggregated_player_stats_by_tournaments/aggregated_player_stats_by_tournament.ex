defmodule GoChampsApi.AggregatedPlayerStatsByTournaments.AggregatedPlayerStatsByTournament do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Players.Player

  schema "aggregated_player_stats_by_tournament" do
    field :stats, :map

    belongs_to :player, Player
    belongs_to :tournament, Tournament

    soft_delete_schema()
    timestamps()
  end

  @doc false
  def changeset(aggregated_player_stats_by_tournament, attrs) do
    aggregated_player_stats_by_tournament
    |> cast(attrs, [:tournament_id, :player_id, :stats])
    |> validate_required([:tournament_id, :player_id, :stats])
  end
end
