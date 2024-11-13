defmodule GoChampsApi.Games.Game do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Phases.Phase
  alias GoChampsApi.Teams.Team

  schema "games" do
    field :away_score, :integer
    field :away_placeholder, :string
    field :datetime, :utc_datetime
    field :home_score, :integer
    field :home_placeholder, :string
    field :info, :string
    field :is_finished, :boolean
    field :location, :string
    field :live_state, Ecto.Enum, values: [:not_started, :running, :ended]

    belongs_to :phase, Phase
    belongs_to :away_team, Team
    belongs_to :home_team, Team

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [
      :datetime,
      :location,
      :away_score,
      :away_placeholder,
      :home_score,
      :home_placeholder,
      :phase_id,
      :info,
      :is_finished,
      :live_state,
      :away_team_id,
      :home_team_id
    ])
    |> validate_required([:phase_id, :live_state])
    |> validate_inclusion(:live_state, [:not_started, :running, :ended])
  end
end
