defmodule GoChampsApi.Repo.Migrations.AddAgainstTeamIdToTeamStatsLog do
  use Ecto.Migration

  def change do
    alter table(:team_stats_log) do
      add :against_team_id, references(:teams, on_delete: :nothing, type: :uuid)
    end

    create index(:team_stats_log, [:against_team_id])
  end
end
