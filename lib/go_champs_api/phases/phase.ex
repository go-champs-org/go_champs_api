defmodule GoChampsApi.Phases.Phase do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Draws.Draw
  alias GoChampsApi.Eliminations.Elimination
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Games.Game

  schema "phases" do
    field :title, :string
    field :type, :string
    field :order, :integer
    field :is_in_progress, :boolean

    embeds_many :elimination_stats, EliminationStats, on_replace: :delete do
      field :title, :string
      field :team_stat_source, :string
      field :ranking_order, :integer
    end

    embeds_many :ranking_tie_breakers, RankingTieBreaker, on_replace: :delete do
      field :type, :string
      field :order, :integer
    end

    belongs_to :tournament, Tournament
    has_many :games, Game
    has_many :draws, Draw
    has_many :eliminations, Elimination

    timestamps()
  end

  @doc false
  def changeset(phase, attrs) do
    phase
    |> cast(attrs, [:title, :type, :order, :is_in_progress, :tournament_id])
    |> cast_embed(:elimination_stats, with: &elimination_stats_changeset/2, required: false)
    |> cast_embed(:ranking_tie_breakers, with: &ranking_tie_breakers_changeset/2, required: false)
    |> validate_required([:title, :type, :tournament_id])
  end

  defp elimination_stats_changeset(schema, params) do
    schema
    |> cast(params, [:title, :team_stat_source, :ranking_order])
    |> validate_required([:title])
  end

  defp ranking_tie_breakers_changeset(schema, params) do
    schema
    |> cast(params, [:type, :order])
    |> validate_required([:type])
    |> validate_inclusion(:type, ["head_to_head"])
  end
end
