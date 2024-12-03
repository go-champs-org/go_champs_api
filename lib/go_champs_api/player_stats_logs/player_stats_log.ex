defmodule GoChampsApi.PlayerStatsLogs.PlayerStatsLog do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Games.Game
  alias GoChampsApi.Teams.Team
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Phases.Phase
  alias GoChampsApi.Players.Player

  schema "player_stats_log" do
    field :stats, :map

    belongs_to :game, Game
    belongs_to :tournament, Tournament
    belongs_to :team, Team
    belongs_to :phase, Phase
    belongs_to :player, Player

    timestamps()
  end

  @doc false
  def changeset(player_stats_log, attrs) do
    player_stats_log
    |> cast(attrs, [
      :stats,
      :game_id,
      :phase_id,
      :player_id,
      :team_id,
      :tournament_id
    ])
    |> validate_required([:stats, :player_id, :tournament_id])
    |> map_stats_id_to_stats_slug()
  end

  defp map_stats_id_to_stats_slug(changeset) do
    case changeset.valid? do
      true ->
        tournament_id = Ecto.Changeset.get_field(changeset, :tournament_id)
        tournament = Tournaments.get_tournament!(tournament_id)

        stats =
          Ecto.Changeset.get_field(changeset, :stats)
          |> map_stats_id_to_stats_slug(tournament)

        Ecto.Changeset.put_change(changeset, :stats, stats)

      false ->
        changeset
    end
  end

  defp map_stats_id_to_stats_slug(stats, tournament) do
    Enum.reduce(stats, %{}, fn {key, value}, acc ->
      case Tournaments.get_player_stat_by_id!(tournament, key) do
        nil -> Map.put(acc, key, value)
        player_stat -> Map.put(acc, player_stat.slug || player_stat.id, value)
      end
    end)
  end
end
