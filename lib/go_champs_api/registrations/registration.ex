defmodule GoChampsApi.Registrations.Registration do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Tournaments.Tournament

  schema "registrations" do
    field :title, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime
    field :type, :string
    field :auto_approve, :boolean, default: false

    embeds_many :custom_fields, CustomField, on_replace: :delete do
      field :type, :string
      field :label, :string
      field :description, :string
    end

    belongs_to :tournament, Tournament

    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [
      :title,
      :start_date,
      :end_date,
      :type,
      :auto_approve,
      :tournament_id
    ])
    |> cast_embed(:custom_fields, with: &custom_field_changeset/2)
    |> validate_required([
      :title,
      :type,
      :tournament_id
    ])
  end

  defp custom_field_changeset(schema, params) do
    schema
    |> cast(params, [:type, :label, :description])
  end
end
