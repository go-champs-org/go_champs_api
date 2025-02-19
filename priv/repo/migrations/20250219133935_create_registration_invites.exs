defmodule GoChampsApi.Repo.Migrations.CreateRegistrationInvites do
  use Ecto.Migration

  def change do
    create table(:registration_invites, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :invitee_type, :string
      add :invitee_id, :uuid

      add :registration_id, references(:registrations, on_delete: :nothing, type: :uuid)

      timestamps()
    end
  end
end
