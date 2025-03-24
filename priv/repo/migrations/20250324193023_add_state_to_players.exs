defmodule GoChampsApi.Repo.Migrations.AddStateToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :state, :string, default: "available"
    end

    execute "UPDATE players SET state = 'available' WHERE state IS NULL"
  end
end
