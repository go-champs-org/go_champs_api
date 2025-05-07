defmodule GoChampsApi.PlayerStatsLogs.PlayerStatsLog do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Sports
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

    soft_delete_schema()
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
    |> calculate_game_level_calculated_statistics()
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
        nil -> Map.put(acc, key, to_string(value))
        player_stat -> Map.put(acc, player_stat.slug || player_stat.id, to_string(value))
      end
    end)
  end

  defp calculate_game_level_calculated_statistics(changeset) do
    case changeset.valid? do
      true ->
        tournament_id = Ecto.Changeset.get_field(changeset, :tournament_id)
        tournament = Tournaments.get_tournament!(tournament_id)

        stats =
          Ecto.Changeset.get_field(changeset, :stats)
          |> calculate_game_level_calculated_statistics(tournament)

        Ecto.Changeset.put_change(changeset, :stats, stats)

      false ->
        changeset
    end
  end

  defp calculate_game_level_calculated_statistics(stats, tournament) do
    calculated_game_level_sport_statistics =
      tournament.sport_slug
      |> Sports.get_game_level_calculated_statistics!()

    Enum.reduce(calculated_game_level_sport_statistics, stats, fn stat, acc ->
      acc
      |> Map.put(stat.slug, to_string(stat.calculation_function.(acc)))
    end)
  end
end
