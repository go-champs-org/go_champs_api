defmodule GoChampsApi.Repo.Migrations.AddCoachesToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :coaches, {:array, :map}, default: []
    end
  end
end
