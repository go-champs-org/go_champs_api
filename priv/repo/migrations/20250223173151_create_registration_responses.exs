defmodule GoChampsApi.Repo.Migrations.CreateRegistrationResponses do
  use Ecto.Migration

  def change do
    create table(:registration_responses, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :response, :map
      add :status, :string

      add :registration_invite_id,
          references(:registration_invites, on_delete: :nothing, type: :uuid)

      timestamps()
    end
  end
end
