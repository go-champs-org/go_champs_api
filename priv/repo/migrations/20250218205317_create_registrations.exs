defmodule GoChampsApi.Repo.Migrations.CreateRegistrations do
  use Ecto.Migration

  def change do
    create table(:registrations, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :type, :string
      add :auto_approve, :boolean, default: false
      add :custom_fields, {:array, :map}, default: []

      add :tournament_id, references(:tournaments, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:registrations, [:tournament_id])
  end
end
