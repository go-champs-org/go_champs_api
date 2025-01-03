defmodule GoChampsApi.AggregatedTeamStatsByPhases do
  @moduledoc """
  The AggregatedTeamStatsByPhases context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo
  alias GoChampsApi.Phases
  alias GoChampsApi.Tournaments
  alias GoChampsApi.TeamStatsLogs.TeamStatsLog

  alias GoChampsApi.AggregatedTeamStatsByPhases.AggregatedTeamStatsByPhase

  @doc """
  Returns the list of aggregated_team_stats_by_phase.

  ## Examples

      iex> list_aggregated_team_stats_by_phase()
      [%AggregatedTeamStatsByPhase{}, ...]

  """
  def list_aggregated_team_stats_by_phase do
    Repo.all(AggregatedTeamStatsByPhase)
  end

  @doc """
  Returns the list of aggregated_team_stats_by_phase filter by keywork param sorted by team stats id.

  ## Examples

      iex> list_aggregated_team_stats_by_phase([name: "some name"], "team-stats-id")
      [%AggregatedTeamStatsByPhase{}, ...]
  """
  def list_aggregated_team_stats_by_phase(where, sort_stat_id, page \\ 0) do
    select_stat = "#{sort_stat_id}"

    query =
      from t in AggregatedTeamStatsByPhase,
        where: ^where,
        limit: 50,
        offset: 50 * ^page,
        order_by: [desc: fragment("(?->>?)::numeric", t.stats, ^select_stat)]

    Repo.all(query)
  end

  @doc """
  Gets a single aggregated_team_stats_by_phase.

  Raises `Ecto.NoResultsError` if the Aggregated team stats by phase does not exist.

  ## Examples

      iex> get_aggregated_team_stats_by_phase!(123)
      %AggregatedTeamStatsByPhase{}

      iex> get_aggregated_team_stats_by_phase!(456)
      ** (Ecto.NoResultsError)

  """
  def get_aggregated_team_stats_by_phase!(id), do: Repo.get!(AggregatedTeamStatsByPhase, id)

  @doc """
  Creates a aggregated_team_stats_by_phase.

  ## Examples

      iex> create_aggregated_team_stats_by_phase(%{field: value})
      {:ok, %AggregatedTeamStatsByPhase{}}

      iex> create_aggregated_team_stats_by_phase(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_aggregated_team_stats_by_phase(attrs \\ %{}) do
    %AggregatedTeamStatsByPhase{}
    |> AggregatedTeamStatsByPhase.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a aggregated_team_stats_by_phase.

  ## Examples

      iex> update_aggregated_team_stats_by_phase(aggregated_team_stats_by_phase, %{field: new_value})
      {:ok, %AggregatedTeamStatsByPhase{}}

      iex> update_aggregated_team_stats_by_phase(aggregated_team_stats_by_phase, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_aggregated_team_stats_by_phase(
        %AggregatedTeamStatsByPhase{} = aggregated_team_stats_by_phase,
        attrs
      ) do
    aggregated_team_stats_by_phase
    |> AggregatedTeamStatsByPhase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a aggregated_team_stats_by_phase.

  ## Examples

      iex> delete_aggregated_team_stats_by_phase(aggregated_team_stats_by_phase)
      {:ok, %AggregatedTeamStatsByPhase{}}

      iex> delete_aggregated_team_stats_by_phase(aggregated_team_stats_by_phase)
      {:error, %Ecto.Changeset{}}

  """
  def delete_aggregated_team_stats_by_phase(
        %AggregatedTeamStatsByPhase{} = aggregated_team_stats_by_phase
      ) do
    Repo.delete(aggregated_team_stats_by_phase)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking aggregated_team_stats_by_phase changes.

  ## Examples

      iex> change_aggregated_team_stats_by_phase(aggregated_team_stats_by_phase)
      %Ecto.Changeset{data: %AggregatedTeamStatsByPhase{}}

  """
  def change_aggregated_team_stats_by_phase(
        %AggregatedTeamStatsByPhase{} = aggregated_team_stats_by_phase,
        attrs \\ %{}
      ) do
    AggregatedTeamStatsByPhase.changeset(aggregated_team_stats_by_phase, attrs)
  end

  @doc """
  Generates a aggregated_team_stats_by_phase by phase id.

  ## Examples

      iex> generate_aggregated_team_stats_for_phase(phase_id)
      %Ecto.Changeset{source: %AggregatedPlayerStatsByTournament{}}

  """
  @spec generate_aggregated_team_stats_for_phase(phase_id :: Ecto.UUID.t()) :: Ecto.Changeset.t()
  def generate_aggregated_team_stats_for_phase(phase_id) do
    phase = Phases.get_phase!(phase_id)

    team_id_query =
      from t in TeamStatsLog,
        where: t.phase_id == ^phase_id,
        group_by: t.team_id,
        select: t.team_id

    teams_ids = Repo.all(team_id_query)

    Enum.each(teams_ids, fn team_id ->
      team_stats_query =
        from t in TeamStatsLog,
          where: t.phase_id == ^phase_id and t.team_id == ^team_id

      team_stats_logs = Repo.all(team_stats_query)

      team_aggregated_stats =
        phase.tournament
        |> Tournaments.get_team_stats_keys()
        |> aggregate_team_stats_from_team_stats_logs(team_stats_logs)

      create_aggregated_team_stats_by_phase(%{
        tournament_id: phase.tournament_id,
        phase_id: phase_id,
        team_id: team_id,
        stats: team_aggregated_stats
      })
    end)
  end

  @doc """
  Aggregates all team stats from a list of team stats logs.

  ## Examples

      iex> aggregate_team_stats_from_team_stats_logs(
      ["points", "rebounds", "1234"],
      [
        %TeamStatsLog{
          team_id: "team-id",
          stats: %{"points" => "2", "rebounds" => "1"}
        },
        %TeamStatsLog{
          team_id: "team-id",
          stats: %{"points" => "3", "rebounds" => "2"}
        }
      ]

  """
  @spec aggregate_team_stats_from_team_stats_logs(
          team_stats_keys :: [String.t()],
          team_stats_logs :: [TeamStatsLog]
        ) :: map()
  def aggregate_team_stats_from_team_stats_logs(team_stats_keys, team_stats_logs) do
    team_stats_logs
    |> Enum.reduce(%{}, fn team_stats_log, aggregated_stats ->
      team_stats_keys
      |> Enum.reduce(aggregated_stats, fn team_stats_key, team_stats_map ->
        # Get the current stat value from the team stats log
        # Remove all non-numeric characters and empty strings

        string_stat_value =
          Map.get(team_stats_log.stats, team_stats_key, "0")
          |> String.replace(~r/\D/, "")
          |> String.trim()

        {current_stat_value, _} =
          case string_stat_value do
            "" -> {0, ""}
            _ -> Float.parse(string_stat_value)
          end

        aggregated_stat_value = Map.get(aggregated_stats, team_stats_key, 0)

        Map.put(team_stats_map, team_stats_key, current_stat_value + aggregated_stat_value)
      end)
    end)
  end
end
