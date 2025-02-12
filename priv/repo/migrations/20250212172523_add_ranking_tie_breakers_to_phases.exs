defmodule GoChampsApi.Repo.Migrations.AddRankingTieBreakersToPhases do
  use Ecto.Migration

  def change do
    alter table(:phases) do
      add :ranking_tie_breakers, {:array, :map}, default: []
    end
  end
end
