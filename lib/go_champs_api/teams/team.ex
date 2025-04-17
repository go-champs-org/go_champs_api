defmodule GoChampsApi.Teams.Team do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Players.Player

  schema "teams" do
    field :name, :string
    field :logo_url, :string
    field :tri_code, :string

    embeds_many :coaches, Coach, on_replace: :delete do
      field :name, :string
      field :type, :string
    end

    belongs_to :tournament, Tournament
    has_many :players, Player

    timestamps()
  end

  @doc false
  def changeset(tournament_team, attrs) do
    tournament_team
    |> cast(attrs, [:name, :tournament_id, :logo_url, :tri_code])
    |> cast_embed(:coaches, with: &coach_changeset/2)
    |> validate_required([:name, :tournament_id])
  end

  defp coach_changeset(schema, params) do
    schema
    |> cast(params, [:name, :type])
    |> validate_required([:name, :type])
  end
end
