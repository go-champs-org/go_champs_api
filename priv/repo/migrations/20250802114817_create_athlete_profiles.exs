defmodule GoChampsApi.Repo.Migrations.CreateAthleteProfiles do
  use Ecto.Migration

  def change do
    create table(:athlete_profiles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :username, :string, null: false
      add :name, :string, null: false
      add :photo, :string
      add :facebook, :string
      add :instagram, :string
      add :twitter, :string

      timestamps()
    end

    create unique_index(:athlete_profiles, [:username])
  end
end
