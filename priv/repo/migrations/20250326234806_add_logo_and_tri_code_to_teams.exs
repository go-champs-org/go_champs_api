defmodule GoChampsApi.Repo.Migrations.AddLogoAndTriCodeToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :logo_url, :string
      add :tri_code, :string
    end
  end
end
