defmodule GoChampsApi.Repo.Migrations.AddNumberAndShirtNameToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :shirt_number, :integer
      add :shirt_name, :string
    end
  end
end
