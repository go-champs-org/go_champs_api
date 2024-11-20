defmodule GoChampsApi.Repo.Migrations.AddSportFieldsToTournaments do
  use Ecto.Migration

  def change do
    alter table(:tournaments) do
      add :sport_slug, :string
      add :sport_name, :string
    end
  end
end
