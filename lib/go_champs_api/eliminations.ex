defmodule GoChampsApi.Eliminations do
  @moduledoc """
  The Eliminations context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.AggregatedTeamStatsByPhases.AggregatedTeamStatsByPhase
  alias GoChampsApi.Phases.Phase
  alias GoChampsApi.Repo

  alias GoChampsApi.Eliminations.Elimination
  alias GoChampsApi.Eliminations.TeamStats
  alias GoChampsApi.Phases

  @doc """
  Gets a single elimination.

  Raises `Ecto.NoResultsError` if the Elimination does not exist.

  ## Examples

      iex> get_elimination!(123)
      %Elimination{}

      iex> get_elimination!(456)
      ** (Ecto.NoResultsError)

  """
  def get_elimination!(id), do: Repo.get!(Elimination, id)

  def get_elimination_organization!(id) do
    {:ok, phase} =
      Repo.get!(Elimination, id)
      |> Repo.preload([:phase])
      |> Map.fetch(:phase)

    Phases.get_phase_organization!(phase.id)
  end

  @doc """
  Gets a eliminations phase id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

  iex> get_eliminations_phase_id([])
  [%Elimination{}]

  iex> get_eliminations_phase_id([])
  ** (Ecto.NoResultsError)

  """
  def get_eliminations_phase_id(eliminations) do
    eliminations_id = Enum.map(eliminations, fn elimination -> elimination["id"] end)

    case Repo.all(
           from elimination in Elimination,
             where: elimination.id in ^eliminations_id,
             group_by: elimination.phase_id,
             select: elimination.phase_id
         ) do
      [phase_id] ->
        {:ok, phase_id}

      _ ->
        {:error, "Can only update elimination from same phase"}
    end
  end

  @doc """
  Creates a elimination.

  ## Examples

      iex> create_elimination(%{field: value})
      {:ok, %Elimination{}}

      iex> create_elimination(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_elimination(attrs \\ %{}) do
    %Elimination{}
    |> Elimination.changeset(attrs)
    |> get_elimination_next_order()
    |> Repo.insert()
  end

  defp get_elimination_next_order(changeset) do
    phase_id = Ecto.Changeset.get_field(changeset, :phase_id)

    query =
      if phase_id do
        from e in Elimination, where: e.phase_id == ^phase_id
      else
        from(e in Elimination)
      end

    number_of_records = Repo.aggregate(query, :count, :id)
    Ecto.Changeset.put_change(changeset, :order, Enum.sum([number_of_records, 1]))
  end

  @doc """
  Updates a elimination.

  ## Examples

      iex> update_elimination(elimination, %{field: new_value})
      {:ok, %Elimination{}}

      iex> update_elimination(elimination, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_elimination(%Elimination{} = elimination, attrs) do
    elimination
    |> Elimination.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates many eliminations.

  ## Examples

      iex> update_eliminations([%{field: new_value}])
      {:ok, [%Phase{}]}

      iex> update_eliminations([%{field: bad_value}])
      {:error, %Ecto.Changeset{}}

  """
  def update_eliminations(eliminations) do
    multi =
      eliminations
      |> Enum.reduce(Ecto.Multi.new(), fn elimination, multi ->
        %{"id" => id} = elimination
        current_elimination = Repo.get_by!(Elimination, id: id)
        changeset = Elimination.changeset(current_elimination, elimination)

        Ecto.Multi.update(multi, id, changeset)
      end)

    Repo.transaction(multi)
  end

  @doc """
  Deletes a Elimination.

  ## Examples

      iex> delete_elimination(elimination)
      {:ok, %Elimination{}}

      iex> delete_elimination(elimination)
      {:error, %Ecto.Changeset{}}

  """
  def delete_elimination(%Elimination{} = elimination) do
    Repo.delete(elimination)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking elimination changes.

  ## Examples

      iex> change_elimination(elimination)
      %Ecto.Changeset{source: %Elimination{}}

  """
  def change_elimination(%Elimination{} = elimination) do
    Elimination.changeset(elimination, %{})
  end

  @doc """
  Sorts elimination team stats by the phase criteria for a given elimination_id.

  ## Examples

      iex> sort_team_stats_based_on_phase_criteria(123)
      {:ok, %Elimination{}}

      iex> sort_team_stats_based_on_phase_criteria(456)
      {:error, %Ecto.Changeset{}}

  """
  @spec sort_team_stats_based_on_phase_criteria(Ecto.UUID.t()) ::
          {:ok, %Elimination{}} | {:error, %Ecto.Changeset{}}
  def sort_team_stats_based_on_phase_criteria(elimination_id) do
    elimination =
      Repo.get!(Elimination, elimination_id)
      |> Repo.preload([:phase])

    updated_team_stats =
      elimination.team_stats
      |> Enum.sort(fn team_stat_a, team_stat_b ->
        elimination.phase
        |> should_team_stats_a_be_placed_before_team_stats_b?(team_stat_a, team_stat_b)
      end)
      |> Enum.map(fn team_stat -> Map.from_struct(team_stat) end)

    elimination
    |> update_elimination(%{team_stats: updated_team_stats})
  end

  @doc """
  Returns true or false if team stats a should be placed before team stats b based on phase criteria.

  ## Examples

      iex> should_team_stats_a_be_placed_before_team_stats_b?(%Phase{}, %TeamStats{}, %TeamStats{})
      true

      iex> should_team_stats_a_be_placed_before_team_stats_b?(%Phase{}, %TeamStats{}, %TeamStats{})
      false
  """
  @spec should_team_stats_a_be_placed_before_team_stats_b?(%Phase{}, %TeamStats{}, %TeamStats{}) ::
          boolean
  def should_team_stats_a_be_placed_before_team_stats_b?(phase, team_stats_a, team_stats_b) do
    # remove all elimination_stats where ranking_order is nil
    Enum.filter(phase.elimination_stats, fn elimination_stat ->
      elimination_stat.ranking_order != nil && elimination_stat.ranking_order > 0
    end)
    |> Enum.sort(fn elimination_stat_a, elimination_stat_b ->
      elimination_stat_a.ranking_order < elimination_stat_b.ranking_order
    end)
    |> Enum.reduce_while(true, fn elimination_stat_a, _acc ->
      stat_a = Map.get(team_stats_a.stats, elimination_stat_a.id, 0)
      stat_b = Map.get(team_stats_b.stats, elimination_stat_a.id, 0)

      case stat_a == stat_b do
        true -> {:cont, true}
        _ -> {:halt, stat_a > stat_b}
      end
    end)
  end

  @doc """
  Update team stats from AggregatedTeamStatsByPhase values for a give elimination id.

  ## Examples

      iex> update_team_stats_from_aggregated_team_stats_by_phase(123)
      {:ok, %Elimination{}}

      iex> update_team_stats_from_aggregated_team_stats_by_phase(456)
      {:error, %Ecto.Changeset{}}
  """
  @spec update_team_stats_from_aggregated_team_stats_by_phase(Ecto.UUID.t()) ::
          {:ok, %Elimination{}} | {:error, %Ecto.Changeset{}}
  def update_team_stats_from_aggregated_team_stats_by_phase(elimination_id) do
    elimination =
      Repo.get!(Elimination, elimination_id)
      |> Repo.preload([:phase])

    updated_team_stats =
      elimination.team_stats
      |> Enum.map(fn team_stat ->
        team_stat
        |> update_stats_values_from_aggregated_team_stats_by_phase(elimination.phase)
        |> Map.from_struct()
      end)

    elimination
    |> update_elimination(%{team_stats: updated_team_stats})
  end

  @doc """
  Update stats value based on phase and AggregatedTeamStatsByPhase values for a given TeamStats.

  ## Examples

      iex> update_stats_values_from_aggregated_team_stats_by_phase(%TeamStats{}, [%EliminationStats{}])
      {:ok, %TeamStats{}}

      iex> update_stats_values_from_aggregated_team_stats_by_phase(%TeamStats{}, [%EliminationStats{}])
      {:error, %Ecto.Changeset{}}
  """
  @spec update_stats_values_from_aggregated_team_stats_by_phase(%TeamStats{}, [
          %Phase{}
        ]) ::
          {:ok, %TeamStats{}} | {:error, %Ecto.Changeset{}}
  def update_stats_values_from_aggregated_team_stats_by_phase(team_stats, phase) do
    case AggregatedTeamStatsByPhases.list_aggregated_team_stats_by_phase(
           phase_id: phase.id,
           team_id: team_stats.team_id
         ) do
      [aggregated_team_stats_by_phase] ->
        team_stats_stats =
          phase.elimination_stats
          |> Enum.reduce(%{}, fn elimination_stat, acc ->
            stat_value =
              aggregated_team_stats_by_phase
              |> retrive_stat_value(elimination_stat.team_stat_source)

            Map.put(acc, elimination_stat.id, stat_value)
          end)

        team_stats
        |> Map.put(:stats, team_stats_stats)

      _ ->
        team_stats
    end
  end

  @doc """
  Retrive stat value from AggregatedTeamStatsByPhase values for a given team stat source.

  ## Examples

      iex> retrive_stat_value(%AggregatedTeamStatsByPhase{stats: %{"kills" => 10}}, "kills")
      10

      iex> retrive_stat_value(%AggregatedTeamStatsByPhase{stats: %{"deaths" => 5}}, "deaths")
      5
  """
  @spec retrive_stat_value(%AggregatedTeamStatsByPhase{}, String.t()) :: any
  def retrive_stat_value(aggregated_team_stats_by_phase, team_stat_source) do
    Map.get(aggregated_team_stats_by_phase.stats, team_stat_source, 0)
  end
end
