defmodule GoChampsApi.TeamStatsLogs.TeamStatsLog do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Games.Game
  alias GoChampsApi.Teams.Team
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Phases.Phase

  schema "team_stats_log" do
    field :stats, :map

    belongs_to :game, Game
    belongs_to :tournament, Tournament
    belongs_to :team, Team
    belongs_to :against_team, Team
    belongs_to :phase, Phase

    soft_delete_schema()
    timestamps()
  end

  @doc false
  def changeset(team_stats_log, attrs) do
    team_stats_log
    |> cast(attrs, [
      :stats,
      :game_id,
      :phase_id,
      :team_id,
      :against_team_id,
      :tournament_id
    ])
    |> validate_required([:stats, :phase_id, :team_id, :against_team_id, :tournament_id])
  end
end
