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

    belongs_to :tournament, Tournament
    has_many :players, Player

    soft_delete_schema()
    timestamps()
  end

  @doc false
  def changeset(tournament_team, attrs) do
    tournament_team
    |> cast(attrs, [:name, :tournament_id, :logo_url, :tri_code])
    |> validate_required([:name, :tournament_id])
  end
end
