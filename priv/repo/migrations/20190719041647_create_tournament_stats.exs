defmodule TournamentsApiWeb.Repo.Migrations.CreateTournamentStats do
  use Ecto.Migration

  def change do
    create table(:tournament_stats, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string

      timestamps()
    end
  end
end
