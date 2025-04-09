defmodule GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases.AggregatedTeamHeadToHeadStatsByPhase do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Phases.Phase
  alias GoChampsApi.Teams.Team
  alias GoChampsApi.Tournaments.Tournament

  schema "aggregated_team_head_to_head_stats_by_phase" do
    field :stats, :map

    belongs_to :team, Team
    belongs_to :phase, Phase
    belongs_to :tournament, Tournament
    belongs_to :against_team, Team

    timestamps()
  end

  @doc false
  def changeset(aggregated_team_head_to_head_stats_by_phase, attrs) do
    aggregated_team_head_to_head_stats_by_phase
    |> cast(attrs, [:team_id, :against_team_id, :tournament_id, :phase_id, :stats])
    |> validate_required([:team_id, :against_team_id, :tournament_id, :phase_id, :stats])
  end
end
