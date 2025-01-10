defmodule GoChampsApi.Repo.Migrations.AddVisibilityToTournaments do
  use Ecto.Migration

  def change do
    alter table(:tournaments) do
      add :visibility, :string, default: "public"
    end

    execute "UPDATE tournaments SET visibility = 'public' WHERE visibility IS NULL"
  end
end
