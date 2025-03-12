defmodule GoChampsApi.Repo.Migrations.CreateScoreboardSettings do
  use Ecto.Migration

  def change do
    create table(:scoreboard_settings, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :view, :string, null: false
      add :initial_period_time, :integer

      add :tournament_id, references(:tournaments, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:scoreboard_settings, [:tournament_id])
  end
end
