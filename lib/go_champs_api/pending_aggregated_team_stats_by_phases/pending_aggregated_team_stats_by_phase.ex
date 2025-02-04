defmodule GoChampsApi.PendingAggregatedTeamStatsByPhases.PendingAggregatedTeamStatsByPhase do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset

  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Phases.Phase

  schema "pending_aggregated_team_stats_by_phase" do
    belongs_to :tournament, Tournament
    belongs_to :phase, Phase

    timestamps()
  end

  @doc false
  def changeset(pending_aggregated_team_stats_by_phase, attrs) do
    pending_aggregated_team_stats_by_phase
    |> cast(attrs, [:tournament_id, :phase_id])
    |> validate_required([:tournament_id, :phase_id])
  end
end
