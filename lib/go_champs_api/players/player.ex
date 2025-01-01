defmodule GoChampsApi.Players.Player do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Teams.Team
  alias GoChampsApi.Tournaments.Tournament

  schema "players" do
    field :facebook, :string
    field :instagram, :string
    field :name, :string
    field :twitter, :string
    field :username, :string
    field :shirt_number, :string
    field :shirt_name, :string

    belongs_to :tournament, Tournament
    belongs_to :team, Team

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [
      :name,
      :username,
      :facebook,
      :instagram,
      :twitter,
      :tournament_id,
      :team_id,
      :shirt_number,
      :shirt_name
    ])
    |> validate_required([:name, :tournament_id])
  end
end
