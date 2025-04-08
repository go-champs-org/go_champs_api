defmodule GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases do
  @moduledoc """
  The AggregatedTeamHeadToHeadStatsByPhases context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases.AggregatedTeamHeadToHeadStatsByPhase

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
end
