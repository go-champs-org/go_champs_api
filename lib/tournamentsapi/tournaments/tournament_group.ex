defmodule TournamentsApi.Tournaments.TournamentGroup do
  use Ecto.Schema
  use TournamentsApi.Schema
  import Ecto.Changeset
  alias TournamentsApi.Tournaments.Tournament

  schema "tournament_groups" do
    field :name, :string

    belongs_to :tournament, Tournament

    timestamps()
  end

  @doc false
  def changeset(tournament_group, attrs) do
    tournament_group
    |> cast(attrs, [:name, :tournament_id])
    |> validate_required([:name, :tournament_id])
  end
end