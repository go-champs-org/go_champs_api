defmodule GoChampsApi.Players.Player do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Teams.Team
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Registrations.RegistrationResponse

  schema "players" do
    field :facebook, :string
    field :instagram, :string
    field :name, :string
    field :twitter, :string
    field :username, :string
    field :shirt_number, :string
    field :shirt_name, :string
    field :state, :string, default: "available"
    field :photo_url, :string

    belongs_to :tournament, Tournament
    belongs_to :team, Team
    belongs_to :registration_response, RegistrationResponse

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
      :shirt_name,
      :registration_response_id,
      :photo_url,
      :state
    ])
    |> validate_required([:name, :tournament_id])
    |> validate_inclusion(:state, ["available", "not_available"])
  end
end
