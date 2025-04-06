defmodule GoChampsApi.PendingAggregatedTeamStatsByPhases do
  @moduledoc """
  The PendingAggregatedTeamStatsByPhases context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.PendingAggregatedTeamStatsByPhases.PendingAggregatedTeamStatsByPhase

  @doc """
  Returns the list of pending_aggregated_team_stats_by_phase.

  ## Examples

      iex> list_pending_aggregated_team_stats_by_phase()
      [%PendingAggregatedTeamStatsByPhase{}, ...]

  """
  def list_pending_aggregated_team_stats_by_phase do
    Repo.all(PendingAggregatedTeamStatsByPhase)
  end

  @doc """
  Returns the list of tournament_ids stored

  ## Examples

      iex> list_tournament_ids()
      ["some-id", ...]

  """
  def list_tournament_ids do
    query =
      from p in PendingAggregatedTeamStatsByPhase,
        group_by: p.tournament_id,
        select: p.tournament_id

    Repo.all(query)
  end

  @doc """
  Returns the list of phase_ids stored

  ## Examples

      iex> list_phase_ids()
      ["some-id", ...]
  """
  @spec list_phase_ids() :: [String.t()]
  def list_phase_ids do
    query =
      from p in PendingAggregatedTeamStatsByPhase,
        group_by: p.phase_id,
        select: p.phase_id

    Repo.all(query)
  end

  @doc """
  Gets a single pending_aggregated_team_stats_by_phase.

  Raises `Ecto.NoResultsError` if the Pending aggregated team stats by phase does not exist.

  ## Examples

      iex> get_pending_aggregated_team_stats_by_phase!(123)
      %PendingAggregatedTeamStatsByPhase{}

      iex> get_pending_aggregated_team_stats_by_phase!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pending_aggregated_team_stats_by_phase!(id),
    do: Repo.get!(PendingAggregatedTeamStatsByPhase, id)

  @doc """
  Creates a pending_aggregated_team_stats_by_phase.

  ## Examples

      iex> create_pending_aggregated_team_stats_by_phase(%{field: value})
      {:ok, %PendingAggregatedTeamStatsByPhase{}}

      iex> create_pending_aggregated_team_stats_by_phase(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pending_aggregated_team_stats_by_phase(attrs \\ %{}) do
    %PendingAggregatedTeamStatsByPhase{}
    |> PendingAggregatedTeamStatsByPhase.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pending_aggregated_team_stats_by_phase.

  ## Examples

      iex> update_pending_aggregated_team_stats_by_phase(pending_aggregated_team_stats_by_phase, %{field: new_value})
      {:ok, %PendingAggregatedTeamStatsByPhase{}}

      iex> update_pending_aggregated_team_stats_by_phase(pending_aggregated_team_stats_by_phase, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pending_aggregated_team_stats_by_phase(
        %PendingAggregatedTeamStatsByPhase{} = pending_aggregated_team_stats_by_phase,
        attrs
      ) do
    pending_aggregated_team_stats_by_phase
    |> PendingAggregatedTeamStatsByPhase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pending_aggregated_team_stats_by_phase.

  ## Examples

      iex> delete_pending_aggregated_team_stats_by_phase(pending_aggregated_team_stats_by_phase)
      {:ok, %PendingAggregatedTeamStatsByPhase{}}

      iex> delete_pending_aggregated_team_stats_by_phase(pending_aggregated_team_stats_by_phase)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pending_aggregated_team_stats_by_phase(
        %PendingAggregatedTeamStatsByPhase{} = pending_aggregated_team_stats_by_phase
      ) do
    Repo.delete(pending_aggregated_team_stats_by_phase)
  end

  @doc """
  Deletes all pending_aggregated_team_stats_by_phase pertaining to a tournament_id.

  ## Examples

      iex> delete_by_tournament_id(pending_aggregated_team_stats_by_phase)
      {:ok, %PendingAggregatedTeamStatsByPhase{}}

      iex> delete_by_tournament_id(pending_aggregated_team_stats_by_phase)
      {:error, %Ecto.Changeset{}}

  """
  def delete_by_tournament_id(tournament_id) do
    query =
      from p in PendingAggregatedTeamStatsByPhase,
        where: p.tournament_id == ^tournament_id

    Repo.delete_all(query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pending_aggregated_team_stats_by_phase changes.

  ## Examples

      iex> change_pending_aggregated_team_stats_by_phase(pending_aggregated_team_stats_by_phase)
      %Ecto.Changeset{data: %PendingAggregatedTeamStatsByPhase{}}

  """
  def change_pending_aggregated_team_stats_by_phase(
        %PendingAggregatedTeamStatsByPhase{} = pending_aggregated_team_stats_by_phase,
        attrs \\ %{}
      ) do
    PendingAggregatedTeamStatsByPhase.changeset(pending_aggregated_team_stats_by_phase, attrs)
  end

  @doc """
  Generates aggregated team stats log for pending tournaments

  ## Examples

      iex> run_pending_aggregated_team_stats_generation()

  """
  def run_pending_aggregated_team_stats_generation() do
  end
end
