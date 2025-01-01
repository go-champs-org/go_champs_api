defmodule GoChampsApi.Repo.Migrations.ChangeNumberTypeToStringInPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      modify :shirt_number, :string
    end
  end
end
