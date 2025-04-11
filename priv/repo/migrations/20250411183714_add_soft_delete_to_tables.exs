defmodule GoChampsApi.Repo.Migrations.AddSoftDeleteToTables do
  use Ecto.Migration
  import Ecto.SoftDelete.Migration

  def change do
    tables = [
      :aggregated_player_stats_by_tournament,
      :aggregated_team_head_to_head_stats_by_phase,
      :aggregated_team_stats_by_phase,
      :draws,
      :eliminations,
      :fixed_player_stats_table,
      :games,
      :organizations,
      :pending_aggregated_team_stats_by_phase,
      :phases,
      :player_stats_log,
      :players,
      :recently_view,
      :registration_invites,
      :registration_responses,
      :registrations,
      :scoreboard_settings,
      :team_stats_log,
      :teams,
      :tournaments,
      :users
    ]

    for table <- tables do
      alter table(table) do
        soft_delete_columns()
      end

      create index(table, [:deleted_at])
    end
  end
end
