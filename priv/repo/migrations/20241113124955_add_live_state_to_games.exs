defmodule GoChampsApi.Repo.Migrations.AddLiveStateToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :live_state, :string, default: "not_started"
    end
  end
end
