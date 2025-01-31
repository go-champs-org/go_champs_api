defmodule GoChampsApi.FixedPlayerStatsTables.FixedPlayerStatsTable do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Tournaments.Tournament

  schema "fixed_player_stats_table" do
    field :stat_id, :binary_id

    embeds_many :player_stats, FixedPlayerStats, on_replace: :delete do
      field :player_id, :binary_id
      field :value, :string
    end

    belongs_to :tournament, Tournament

    timestamps()
  end

  @doc false
  def changeset(fixed_player_stats_table, attrs) do
    fixed_player_stats_table
    |> cast(attrs, [
      :stat_id,
      :tournament_id
    ])
    |> cast_embed(:player_stats, with: &player_stats_changeset/2, required: true)
    |> validate_required([:stat_id, :tournament_id])
  end

  defp player_stats_changeset(schema, params) do
    schema
    |> cast(params, [:player_id, :value])
    |> validate_required([:player_id, :value])
  end
end
