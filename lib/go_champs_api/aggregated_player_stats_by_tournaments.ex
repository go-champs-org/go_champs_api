defmodule GoChampsApi.AggregatedPlayerStatsByTournaments do
  @moduledoc """
  The AggregatedPlayerStatsByTournaments context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Sports
  alias GoChampsApi.Repo

  alias GoChampsApi.PlayerStatsLogs.PlayerStatsLog
  alias GoChampsApi.PlayerStatsLogs
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
        player_stats_logs
        |> PlayerStatsLogs.aggregate_and_calculate_player_stats_from_player_stats_logs()

      per_game_aggregated_stats =
        Sports.get_tournament_level_per_game_statistics!(tournament.sport_slug)
        |> PlayerStatsLogs.calculate_player_stats(player_aggregated_stats)

      create_aggregated_player_stats_by_tournament(%{
        tournament_id: tournament_id,
        player_id: player_id,
        stats: per_game_aggregated_stats
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
end
