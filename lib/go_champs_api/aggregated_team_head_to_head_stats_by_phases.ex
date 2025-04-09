defmodule GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases do
  @moduledoc """
  The AggregatedTeamHeadToHeadStatsByPhases context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases.AggregatedTeamHeadToHeadStatsByPhase
  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.TeamStatsLogs.TeamStatsLog
  alias GoChampsApi.Phases
  alias GoChampsApi.Tournaments

  @doc """
  Returns the list of aggregated_team_head_to_head_stats_by_phase.

  ## Examples

      iex> list_aggregated_team_head_to_head_stats_by_phase()
      [%AggregatedTeamHeadToHeadStatsByPhase{}, ...]

  """
  def list_aggregated_team_head_to_head_stats_by_phase do
    Repo.all(AggregatedTeamHeadToHeadStatsByPhase)
  end

  @doc """
  Returns the list of aggregated_team_head_to_head_stats_by_phase with given where.
  ## Examples

      iex> list_aggregated_team_head_to_head_stats_by_phase([name: "some name"])
      [%AggregatedTeamHeadToHeadStatsByPhase{}, ...]

  """
  def list_aggregated_team_head_to_head_stats_by_phase(where) do
    query =
      from t in AggregatedTeamHeadToHeadStatsByPhase,
        where: ^where

    Repo.all(query)
  end

  @doc """
  Gets a single aggregated_team_head_to_head_stats_by_phase.

  Raises `Ecto.NoResultsError` if the Aggregated team head to head stats by phase does not exist.

  ## Examples

      iex> get_aggregated_team_head_to_head_stats_by_phase!(123)
      %AggregatedTeamHeadToHeadStatsByPhase{}

      iex> get_aggregated_team_head_to_head_stats_by_phase!(456)
      ** (Ecto.NoResultsError)

  """
  def get_aggregated_team_head_to_head_stats_by_phase!(id),
    do: Repo.get!(AggregatedTeamHeadToHeadStatsByPhase, id)

  @doc """
  Creates a aggregated_team_head_to_head_stats_by_phase.

  ## Examples

      iex> create_aggregated_team_head_to_head_stats_by_phase(%{field: value})
      {:ok, %AggregatedTeamHeadToHeadStatsByPhase{}}

      iex> create_aggregated_team_head_to_head_stats_by_phase(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_aggregated_team_head_to_head_stats_by_phase(attrs \\ %{}) do
    %AggregatedTeamHeadToHeadStatsByPhase{}
    |> AggregatedTeamHeadToHeadStatsByPhase.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a aggregated_team_head_to_head_stats_by_phase.

  ## Examples

      iex> update_aggregated_team_head_to_head_stats_by_phase(aggregated_team_head_to_head_stats_by_phase, %{field: new_value})
      {:ok, %AggregatedTeamHeadToHeadStatsByPhase{}}

      iex> update_aggregated_team_head_to_head_stats_by_phase(aggregated_team_head_to_head_stats_by_phase, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_aggregated_team_head_to_head_stats_by_phase(
        %AggregatedTeamHeadToHeadStatsByPhase{} = aggregated_team_head_to_head_stats_by_phase,
        attrs
      ) do
    aggregated_team_head_to_head_stats_by_phase
    |> AggregatedTeamHeadToHeadStatsByPhase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a aggregated_team_head_to_head_stats_by_phase.

  ## Examples

      iex> delete_aggregated_team_head_to_head_stats_by_phase(aggregated_team_head_to_head_stats_by_phase)
      {:ok, %AggregatedTeamHeadToHeadStatsByPhase{}}

      iex> delete_aggregated_team_head_to_head_stats_by_phase(aggregated_team_head_to_head_stats_by_phase)
      {:error, %Ecto.Changeset{}}

  """
  def delete_aggregated_team_head_to_head_stats_by_phase(
        %AggregatedTeamHeadToHeadStatsByPhase{} = aggregated_team_head_to_head_stats_by_phase
      ) do
    Repo.delete(aggregated_team_head_to_head_stats_by_phase)
  end

  @doc """
  Deletes all aggregated_team_head_to_head_stats_by_phase for a give phase id.

  ## Examples

      iex> delete_aggregated_team_head_to_head_stats_by_phase_id("7488a646-e31f-11e4-aace-600308960668")
      {:ok, %Ecto.Changeset{}}

      iex> delete_aggregated_team_head_to_head_stats_by_phase_id("invalid-id")
      {:error, "No data found for the given phase id"}
  """
  @spec delete_aggregated_team_head_to_head_stats_by_phase_id(Ecto.UUID.t()) ::
          {:ok, list(AggregatedTeamHeadToHeadStatsByPhase.t())} | {:error, String.t()}
  def delete_aggregated_team_head_to_head_stats_by_phase_id(phase_id) do
    aggregated_team_head_to_head_stats_by_phase_query =
      from t in AggregatedTeamHeadToHeadStatsByPhase,
        where: t.phase_id == ^phase_id

    Repo.delete_all(aggregated_team_head_to_head_stats_by_phase_query)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking aggregated_team_head_to_head_stats_by_phase changes.

  ## Examples

      iex> change_aggregated_team_head_to_head_stats_by_phase(aggregated_team_head_to_head_stats_by_phase)
      %Ecto.Changeset{data: %AggregatedTeamHeadToHeadStatsByPhase{}}

  """
  def change_aggregated_team_head_to_head_stats_by_phase(
        %AggregatedTeamHeadToHeadStatsByPhase{} = aggregated_team_head_to_head_stats_by_phase,
        attrs \\ %{}
      ) do
    AggregatedTeamHeadToHeadStatsByPhase.changeset(
      aggregated_team_head_to_head_stats_by_phase,
      attrs
    )
  end

  @doc """
  Generates a list of aggregated team head to head stats by phase for a given phase id.

  ## Examples

      iex> generate_aggregated_team_head_to_head_stats_by_phase("7488a646-e31f-11e4-aace-600308960668")
      {:ok, [%AggregatedTeamHeadToHeadStatsByPhase{}, ...]}

      iex> generate_aggregated_team_head_to_head_stats_by_phase("invalid-id")
      {:error, "No data found for the given phase id"}
  """
  @spec generate_aggregated_team_head_to_head_stats_by_phase(Ecto.UUID.t()) ::
          {:ok, list(AggregatedTeamHeadToHeadStatsByPhase.t())} | {:error, String.t()}
  def generate_aggregated_team_head_to_head_stats_by_phase(phase_id) do
    phase = Phases.get_phase!(phase_id)

    team_id_query =
      from t in TeamStatsLog,
        where: t.phase_id == ^phase_id,
        group_by: t.team_id,
        select: t.team_id

    teams_ids = Repo.all(team_id_query)

    Enum.each(teams_ids, fn team_id ->
      against_team_id_query =
        from t in TeamStatsLog,
          where: t.phase_id == ^phase_id and t.team_id == ^team_id,
          group_by: t.against_team_id,
          select: t.against_team_id

      against_team_ids = Repo.all(against_team_id_query)

      Enum.each(against_team_ids, fn against_team_id ->
        team_stats_logs_query =
          from t in TeamStatsLog,
            where:
              t.phase_id == ^phase_id and t.team_id == ^team_id and
                t.against_team_id == ^against_team_id

        team_stats_logs = Repo.all(team_stats_logs_query)

        team_aggregated_head_to_head_stats =
          phase.tournament
          |> Tournaments.get_team_stats_keys()
          |> AggregatedTeamStatsByPhases.aggregate_team_stats_from_team_stats_logs(
            team_stats_logs
          )

        create_aggregated_team_head_to_head_stats_by_phase(%{
          tournament_id: phase.tournament_id,
          phase_id: phase_id,
          team_id: team_id,
          against_team_id: against_team_id,
          stats: team_aggregated_head_to_head_stats
        })
      end)
    end)
  end
end
