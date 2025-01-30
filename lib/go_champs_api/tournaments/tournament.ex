defmodule GoChampsApi.Tournaments.Tournament do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Organizations.Organization
  alias GoChampsApi.Phases.Phase
  alias GoChampsApi.Players.Player
  alias GoChampsApi.Teams.Team
  alias GoChampsApi.Sports

  schema "tournaments" do
    field :name, :string
    field :slug, :string
    field :organization_slug, :string
    field :facebook, :string
    field :instagram, :string
    field :site_url, :string
    field :twitter, :string
    field :has_aggregated_player_stats, :boolean
    field :sport_slug, :string
    field :sport_name, :string
    field :visibility, :string, default: "public"

    embeds_many :player_stats, PlayerStats, on_replace: :delete do
      field :title, :string
      field :slug, :string
      field :is_default_order, :boolean
    end

    embeds_many :team_stats, TeamStats, on_replace: :delete do
      field :title, :string
      field :source, :string
      field :slug, :string
      field :is_default_order, :boolean
    end

    belongs_to :organization, Organization
    has_many :phases, Phase
    has_many :players, Player
    has_many :teams, Team

    timestamps()
  end

  @doc false
  def changeset(tournament, attrs) do
    tournament
    |> cast(attrs, [
      :name,
      :slug,
      :organization_id,
      :facebook,
      :instagram,
      :site_url,
      :twitter,
      :organization_slug,
      :sport_slug,
      :sport_name,
      :visibility
    ])
    |> cast_embed(:player_stats, with: &player_stats_changeset/2, required: false)
    |> cast_embed(:team_stats, with: &team_stats_changeset/2, required: false)
    |> validate_required([:name, :slug, :organization_id])
    |> validate_format(:slug, ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/)
    |> unique_constraint(:slug, name: :tournaments_slug_organization_id_index)
    |> validate_sport_slug()
    |> validate_inclusion(:visibility, ["public", "private"])
  end

  defp player_stats_changeset(schema, params) do
    schema
    |> cast(params, [:title, :slug, :is_default_order])
    |> validate_required([:title])
  end

  defp team_stats_changeset(schema, params) do
    schema
    |> cast(params, [:title, :slug, :source, :is_default_order])
    |> validate_required([:title])
  end

  defp validate_sport_slug(changeset) do
    sports_slug = Enum.map(Sports.list_sports(), & &1.slug)
    validate_inclusion(changeset, :sport_slug, sports_slug)
  end
end
