defmodule GoChampsApi.AggregatedTeamStatsByPhases.AggregatedTeamStatsByPhase do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Phases.Phase
  alias GoChampsApi.Teams.Team
  alias GoChampsApi.Tournaments.Tournament

  schema "aggregated_team_stats_by_phase" do
    field :stats, :map

    belongs_to :team, Team
    belongs_to :phase, Phase
    belongs_to :tournament, Tournament

    soft_delete_schema()
    timestamps()
  end

  @doc false
  def changeset(aggregated_team_stats_by_phase, attrs) do
    aggregated_team_stats_by_phase
    |> cast(attrs, [:stats])
    |> cast(attrs, [:phase_id, :tournament_id, :team_id, :stats])
    |> validate_required([:phase_id, :tournament_id, :team_id, :stats])
  end
end
