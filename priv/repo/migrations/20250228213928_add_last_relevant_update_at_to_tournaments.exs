defmodule GoChampsApi.Repo.Migrations.AddLastRelevantUpdateAtToTournaments do
  use Ecto.Migration

  def change do
    alter table(:tournaments) do
      add :last_relevant_update_at, :utc_datetime
    end
  end
end
