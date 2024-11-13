defmodule GoChampsApi.Repo.Migrations.AddLiveStartedAtAndLiveEndedAtToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :live_started_at, :utc_datetime
      add :live_ended_at, :utc_datetime
    end
  end
end
