defmodule TournamentsApi.Tournaments.TournamentGroup do
  use Ecto.Schema
  use TournamentsApi.Schema
  import Ecto.Changeset
  alias TournamentsApi.Tournaments.Tournament
  alias TournamentsApi.Tournaments.TournamentPhase
  alias TournamentsApi.Tournaments.TournamentTeam

  schema "tournament_groups" do
    field :name, :string

    belongs_to :tournament_phase, TournamentPhase

    has_many :teams, TournamentTeam

    timestamps()
  end

  @doc false
  def changeset(tournament_group, attrs) do
    tournament_group
    |> cast(attrs, [:name, :tournament_phase_id])
    |> validate_required([:name, :tournament_phase_id])
  end
end
