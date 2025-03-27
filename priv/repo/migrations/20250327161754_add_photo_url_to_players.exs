defmodule GoChampsApi.Repo.Migrations.AddPhotoUrlToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :photo_url, :string
    end
  end
end
