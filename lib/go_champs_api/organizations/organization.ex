defmodule GoChampsApi.Organizations.Organization do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Tournaments.Tournament

  schema "organizations" do
    field :slug, :string
    field :name, :string

    embeds_many :members, Member, on_replace: :delete do
      field :username, :string
    end

    has_many :tournaments, Tournament

    soft_delete_schema()
    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :slug])
    |> cast_embed(:members, with: &member_changeset/2, required: false)
    |> validate_required([:name, :slug])
    |> validate_format(:slug, ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/)
    |> unique_constraint(:slug)
  end

  defp member_changeset(schema, params) do
    schema
    |> cast(params, [:username])
  end
end
