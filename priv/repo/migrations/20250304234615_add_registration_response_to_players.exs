defmodule GoChampsApi.Repo.Migrations.AddRegistrationResponseToPlayers do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :registration_response_id,
          references(:registration_responses, on_delete: :nothing, type: :uuid)
    end

    create index(:players, [:registration_response_id])
  end
end
