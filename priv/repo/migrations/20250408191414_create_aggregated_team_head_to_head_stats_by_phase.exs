defmodule GoChampsApi.Repo.Migrations.CreateAggregatedTeamHeadToHeadStatsByPhase do
  use Ecto.Migration

  def change do
    create table(:aggregated_team_head_to_head_stats_by_phase, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :team_id, :uuid
      add :against_team_id, :uuid
      add :tournament_id, :uuid
      add :phase_id, :uuid
      add :stats, :map

      timestamps()
    end

    create index(:aggregated_team_head_to_head_stats_by_phase, [:phase_id])
    create index(:aggregated_team_head_to_head_stats_by_phase, [:tournament_id])
    create index(:aggregated_team_head_to_head_stats_by_phase, [:team_id])
    create index(:aggregated_team_head_to_head_stats_by_phase, [:against_team_id])
  end
end
