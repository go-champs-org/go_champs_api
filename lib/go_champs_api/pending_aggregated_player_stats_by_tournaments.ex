defmodule GoChampsApi.PendingAggregatedPlayerStatsByTournaments do
  @moduledoc """
  The PendingAggregatedPlayerStatsByTournaments context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.PendingAggregatedPlayerStatsByTournaments.PendingAggregatedPlayerStatsByTournament

  @doc """
  Returns the list of pending_aggregated_player_stats_by_tournament.

  ## Examples

      iex> list_pending_aggregated_player_stats_by_tournament()
      [%PendingAggregatedPlayerStatsByTournament{}, ...]

  """
  def list_pending_aggregated_player_stats_by_tournament do
    Repo.all(PendingAggregatedPlayerStatsByTournament)
  end

  @doc """
  Gets a single pending_aggregated_player_stats_by_tournament.

  Raises `Ecto.NoResultsError` if the Pending aggregated player stats by tournament does not exist.

  ## Examples

      iex> get_pending_aggregated_player_stats_by_tournament!(123)
      %PendingAggregatedPlayerStatsByTournament{}

      iex> get_pending_aggregated_player_stats_by_tournament!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pending_aggregated_player_stats_by_tournament!(id),
    do: Repo.get!(PendingAggregatedPlayerStatsByTournament, id)

  @doc """
  Creates a pending_aggregated_player_stats_by_tournament.

  ## Examples

      iex> create_pending_aggregated_player_stats_by_tournament(%{field: value})
      {:ok, %PendingAggregatedPlayerStatsByTournament{}}

      iex> create_pending_aggregated_player_stats_by_tournament(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pending_aggregated_player_stats_by_tournament(attrs \\ %{}) do
    %PendingAggregatedPlayerStatsByTournament{}
    |> PendingAggregatedPlayerStatsByTournament.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pending_aggregated_player_stats_by_tournament.

  ## Examples

      iex> update_pending_aggregated_player_stats_by_tournament(pending_aggregated_player_stats_by_tournament, %{field: new_value})
      {:ok, %PendingAggregatedPlayerStatsByTournament{}}

      iex> update_pending_aggregated_player_stats_by_tournament(pending_aggregated_player_stats_by_tournament, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pending_aggregated_player_stats_by_tournament(
        %PendingAggregatedPlayerStatsByTournament{} =
          pending_aggregated_player_stats_by_tournament,
        attrs
      ) do
    pending_aggregated_player_stats_by_tournament
    |> PendingAggregatedPlayerStatsByTournament.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pending_aggregated_player_stats_by_tournament.

  ## Examples

      iex> delete_pending_aggregated_player_stats_by_tournament(pending_aggregated_player_stats_by_tournament)
      {:ok, %PendingAggregatedPlayerStatsByTournament{}}

      iex> delete_pending_aggregated_player_stats_by_tournament(pending_aggregated_player_stats_by_tournament)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pending_aggregated_player_stats_by_tournament(
        %PendingAggregatedPlayerStatsByTournament{} =
          pending_aggregated_player_stats_by_tournament
      ) do
    Repo.delete(pending_aggregated_player_stats_by_tournament)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pending_aggregated_player_stats_by_tournament changes.

  ## Examples

      iex> change_pending_aggregated_player_stats_by_tournament(pending_aggregated_player_stats_by_tournament)
      %Ecto.Changeset{source: %PendingAggregatedPlayerStatsByTournament{}}

  """
  def change_pending_aggregated_player_stats_by_tournament(
        %PendingAggregatedPlayerStatsByTournament{} =
          pending_aggregated_player_stats_by_tournament
      ) do
    PendingAggregatedPlayerStatsByTournament.changeset(
      pending_aggregated_player_stats_by_tournament,
      %{}
    )
  end
end
