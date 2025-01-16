defmodule GoChampsApi.Repo.Migrations.AddYoutubeCodeToGame do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :youtube_code, :string
    end
  end
end
