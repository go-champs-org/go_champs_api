defmodule GoChampsApi.AggregatedPlayerStatsByTournaments do
  @moduledoc """
  The AggregatedPlayerStatsByTournaments context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Sports
  alias GoChampsApi.Sports.Statistic
  alias GoChampsApi.Tournaments.Tournament.PlayerStats
  alias GoChampsApi.Repo

  alias GoChampsApi.PlayerStatsLogs.PlayerStatsLog
  alias GoChampsApi.Tournaments
  alias GoChampsApi.AggregatedPlayerStatsByTournaments.AggregatedPlayerStatsByTournament

  @doc """
  Returns the list of aggregated_player_stats_by_tournament.

  ## Examples

      iex> list_aggregated_player_stats_by_tournament()
      [%AggregatedPlayerStatsByTournament{}, ...]

  """
  def list_aggregated_player_stats_by_tournament do
    Repo.all(AggregatedPlayerStatsByTournament)
  end

  @doc """
  Returns the list of aggregated_player_stats_by_tournaments filter by keywork param sorted by player stats id.

  ## Examples

      iex> list_aggregated_player_stats_by_tournament([name: "some name"], "player-stats-id")
      [%AggregatedPlayerStatsByTournament{}, ...]

  """
  def list_aggregated_player_stats_by_tournament(where, sort_stat_id, page \\ 0) do
    select_stat = "#{sort_stat_id}"

    query =
      from t in AggregatedPlayerStatsByTournament,
        where: ^where,
        limit: 50,
        offset: 50 * ^page,
        order_by: [desc: fragment("(?->>?)::numeric", t.stats, ^select_stat)]

    Repo.all(query)
  end

  @doc """
  Gets a single aggregated_player_stats_by_tournament.

  Raises `Ecto.NoResultsError` if the Aggregated player stats by tournament does not exist.

  ## Examples

      iex> get_aggregated_player_stats_by_tournament!(123)
      %AggregatedPlayerStatsByTournament{}

      iex> get_aggregated_player_stats_by_tournament!(456)
      ** (Ecto.NoResultsError)

  """
  def get_aggregated_player_stats_by_tournament!(id),
    do: Repo.get!(AggregatedPlayerStatsByTournament, id)

  @doc """
  Creates a aggregated_player_stats_by_tournament.

  ## Examples

      iex> create_aggregated_player_stats_by_tournament(%{field: value})
      {:ok, %AggregatedPlayerStatsByTournament{}}

      iex> create_aggregated_player_stats_by_tournament(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_aggregated_player_stats_by_tournament(attrs \\ %{}) do
    %AggregatedPlayerStatsByTournament{}
    |> AggregatedPlayerStatsByTournament.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a aggregated_player_stats_by_tournament.

  ## Examples

      iex> update_aggregated_player_stats_by_tournament(aggregated_player_stats_by_tournament, %{field: new_value})
      {:ok, %AggregatedPlayerStatsByTournament{}}

      iex> update_aggregated_player_stats_by_tournament(aggregated_player_stats_by_tournament, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_aggregated_player_stats_by_tournament(
        %AggregatedPlayerStatsByTournament{} = aggregated_player_stats_by_tournament,
        attrs
      ) do
    aggregated_player_stats_by_tournament
    |> AggregatedPlayerStatsByTournament.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a aggregated_player_stats_by_tournament.

  ## Examples

      iex> delete_aggregated_player_stats_by_tournament(aggregated_player_stats_by_tournament)
      {:ok, %AggregatedPlayerStatsByTournament{}}

      iex> delete_aggregated_player_stats_by_tournament(aggregated_player_stats_by_tournament)
      {:error, %Ecto.Changeset{}}

  """
  def delete_aggregated_player_stats_by_tournament(
        %AggregatedPlayerStatsByTournament{} = aggregated_player_stats_by_tournament
      ) do
    Repo.delete(aggregated_player_stats_by_tournament)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking aggregated_player_stats_by_tournament changes.

  ## Examples

      iex> change_aggregated_player_stats_by_tournament(aggregated_player_stats_by_tournament)
      %Ecto.Changeset{source: %AggregatedPlayerStatsByTournament{}}

  """
  def change_aggregated_player_stats_by_tournament(
        %AggregatedPlayerStatsByTournament{} = aggregated_player_stats_by_tournament
      ) do
    AggregatedPlayerStatsByTournament.changeset(aggregated_player_stats_by_tournament, %{})
  end

  @doc """
  Generates a aggregated_player_stats_by_tournament by tournament id.

  ## Examples

      iex> generate_aggregated_player_stats_for_tournament(tournament_id)
      %Ecto.Changeset{source: %AggregatedPlayerStatsByTournament{}}

  """
  def generate_aggregated_player_stats_for_tournament(tournament_id) do
    tournament = Tournaments.get_tournament!(tournament_id)

    player_id_query =
      from p in PlayerStatsLog,
        where: p.tournament_id == ^tournament_id,
        group_by: p.player_id,
        select: p.player_id

    players_id = Repo.all(player_id_query)

    Enum.each(players_id, fn player_id ->
      player_stats_query =
        from p in PlayerStatsLog,
          where: p.tournament_id == ^tournament_id and p.player_id == ^player_id

      player_stats_logs = Repo.all(player_stats_query)

      player_aggregated_stats =
        tournament
        |> Tournaments.get_player_stats_keys()
        |> aggregate_player_stats_from_player_stats_logs(player_stats_logs)

      calculated_aggregated_stats =
        Sports.get_calculated_player_calculated_statistics!(tournament.sport_slug)
        |> calculate_player_stats(player_aggregated_stats)

      create_aggregated_player_stats_by_tournament(%{
        tournament_id: tournament_id,
        player_id: player_id,
        stats: calculated_aggregated_stats
      })
    end)
  end

  @doc """
  Deletes a aggregated_player_stats_by_tournament by tournament id.

  ## Examples

      iex> generate_aggregated_player_stats_for_tournament(tournament_id)
      %Ecto.Changeset{source: %AggregatedPlayerStatsByTournament{}}

  """
  def delete_aggregated_player_stats_for_tournament(tournament_id) do
    query =
      from t in AggregatedPlayerStatsByTournament,
        where: [tournament_id: ^tournament_id]

    Repo.delete_all(query)
  end

  @doc """
  Aggregates all player stats from a list of player stats logs.

  ## Examples

      iex> aggregate_player_stats_from_player_stats_logs(
        ["points", "rebounds", "1234"],
        [%PlayerStatsLog{player_id: "player-id", tournament_id: "tournament-id", stats: %{"points" => "2", "rebounds" => "1"}},
          %PlayerStatsLog{player_id: "player-id", tournament_id: "tournament-id", stats: %{"points" => "3", "rebounds" => "2"}}
        ])
      %${"points" => 5, "rebounds" => 3}
  """
  @spec aggregate_player_stats_from_player_stats_logs(
          player_stats_keys :: [string()],
          player_stats_logs :: [PlayerStatsLog]
        ) :: map()
  def aggregate_player_stats_from_player_stats_logs(player_stats_keys, player_stats_logs) do
    player_stats_logs
    |> Enum.reduce(%{}, fn player_stats_log, aggregated_stats ->
      player_stats_keys
      |> Enum.reduce(aggregated_stats, fn player_stats_key, player_stats_map ->
        # Get the current stat value from the player stats log
        # Remove all non-numeric characters and empty strings

        string_stat_value =
          Map.get(player_stats_log.stats, player_stats_key, "0")
          |> String.replace(~r/\D/, "")
          |> String.trim()

        {current_stat_value, _} =
          case string_stat_value do
            "" -> {0, ""}
            _ -> Float.parse(string_stat_value)
          end

        aggregated_stat_value = Map.get(aggregated_stats, player_stats_key, 0)

        Map.put(player_stats_map, player_stats_key, current_stat_value + aggregated_stat_value)
      end)
    end)
  end

  @doc """
  Calculate the player stats that are calculated.

  ## Examples

      iex> calculate_player_stats(%AggregatedPlayerStatsByTournament{})
      %AggregatedPlayerStatsByTournament{}

  """
  @spec calculate_player_stats([%Statistic{}], map()) :: map()
  def calculate_player_stats(sport_statistics, aggregated_stats) do
    Enum.reduce(sport_statistics, aggregated_stats, fn statistic, acc ->
      case statistic.calculation_function do
        nil ->
          acc

        calculation_function ->
          statistic_value = aggregated_stats |> calculation_function.()
          Map.put(acc, statistic.slug, statistic_value)
      end
    end)
  end
end
