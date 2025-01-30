defmodule GoChampsApi.TeamStatsLogs do
  @moduledoc """
  The TeamStatsLogs context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.TeamStatsLogs.TeamStatsLog
  alias GoChampsApi.Games.Game
  alias GoChampsApi.PendingAggregatedTeamStatsByPhases.PendingAggregatedTeamStatsByPhase

  @doc """
  Returns the list of team_stats_log.

  ## Examples

      iex> list_team_stats_log()
      [%TeamStatsLog{}, ...]

  """
  def list_team_stats_log do
    Repo.all(TeamStatsLog)
  end

  @doc """
  Returns the list of Team Stats Logs filter by keywork param.

  ## Examples

      iex> list_team_stats_log([game_id: "game-id"])
      [%TeamStatsLog{}, ...]

  """
  def list_team_stats_log(where) do
    query = from t in TeamStatsLog, where: ^where
    Repo.all(query)
  end

  @doc """
  Gets a single team_stats_log.

  Raises `Ecto.NoResultsError` if the Team stats log does not exist.

  ## Examples

      iex> get_team_stats_log!(123)
      %TeamStatsLog{}

      iex> get_team_stats_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_stats_log!(id), do: Repo.get!(TeamStatsLog, id)

  @doc """
  Gets a team stats log organization for a given team stats log id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_team_organization!(123)
      %Tournament{}

      iex> get_team_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_stats_log_organization!(id) do
    {:ok, tournament} =
      Repo.get_by!(TeamStatsLog, id: id)
      |> Repo.preload(tournament: :organization)
      |> Map.fetch(:tournament)

    {:ok, organization} =
      tournament
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Gets a team_stats_logs tournament id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

  iex> get_team_stats_logs_tournament_id!(123)
  %Tournament{}

  iex> get_team_stats_logs_tournament_id!(456)
  ** (Ecto.NoResultsError)

  """
  def get_team_stats_logs_tournament_id(team_stats_logs) do
    team_stats_logs_id = Enum.map(team_stats_logs, fn team_stats_log -> team_stats_log["id"] end)

    case Repo.all(
           from team_stats_log in TeamStatsLog,
             where: team_stats_log.id in ^team_stats_logs_id,
             group_by: team_stats_log.tournament_id,
             select: team_stats_log.tournament_id
         ) do
      [tournament_id] ->
        {:ok, tournament_id}

      _ ->
        {:error, "Can only update team_stats_log from same tournament"}
    end
  end

  @doc """
  Creates a team_stats_log.

  ## Examples

      iex> create_team_stats_log(%{field: value})
      {:ok, %TeamStatsLog{}}

      iex> create_team_stats_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team_stats_log(attrs \\ %{}) do
    team_stats_logs_changeset =
      %TeamStatsLog{}
      |> TeamStatsLog.changeset(attrs)

    case team_stats_logs_changeset.valid? do
      false ->
        {:error, team_stats_logs_changeset}

      true ->
        pending_aggregated_team_stats_by_phase = %{
          phase_id: Ecto.Changeset.get_change(team_stats_logs_changeset, :phase_id),
          tournament_id: Ecto.Changeset.get_change(team_stats_logs_changeset, :tournament_id)
        }

        pending_aggregated_team_stats_by_phase_changeset =
          %PendingAggregatedTeamStatsByPhase{}
          |> PendingAggregatedTeamStatsByPhase.changeset(pending_aggregated_team_stats_by_phase)

        {:ok, %{team_stats_logs: team_stats_logs}} =
          Ecto.Multi.new()
          |> Ecto.Multi.insert(:team_stats_logs, team_stats_logs_changeset)
          |> Ecto.Multi.insert(
            :pending_aggregated_team_stats_by_phase,
            pending_aggregated_team_stats_by_phase_changeset
          )
          |> Repo.transaction()

        {:ok, team_stats_logs}
    end
  end

  @doc """
  Create many team stats logs.

  ## Examples

      iex> create_team_stats_logs([%{field: new_value}])
      {:ok, [%TeamStatsLog{}]}

      iex> create_team_stats_logs([%{field: bad_value}])
      {:error, %Ecto.Changeset{}}

  """
  def create_team_stats_logs(team_stats_logs) do
    {multi_team_stats_logs, _} =
      team_stats_logs
      |> Enum.reduce({Ecto.Multi.new(), 0}, fn team_stats_log, {multi_team_stats_logs, index} ->
        changeset =
          %TeamStatsLog{}
          |> TeamStatsLog.changeset(team_stats_log)

        {Ecto.Multi.insert(multi_team_stats_logs, index, changeset), index + 1}
      end)

    case Enum.count(team_stats_logs) do
      0 ->
        Repo.transaction(multi_team_stats_logs)

      _ ->
        first_changeset =
          %TeamStatsLog{}
          |> TeamStatsLog.changeset(List.first(team_stats_logs))

        pending_aggregated_team_stats_by_phase = %{
          phase_id: Ecto.Changeset.get_change(first_changeset, :phase_id),
          tournament_id: Ecto.Changeset.get_change(first_changeset, :tournament_id)
        }

        pending_aggregated_team_stats_by_phase_changeset =
          %PendingAggregatedTeamStatsByPhase{}
          |> PendingAggregatedTeamStatsByPhase.changeset(pending_aggregated_team_stats_by_phase)

        multi_team_stats_logs_and_pending_aggregated_team_stats =
          multi_team_stats_logs
          |> Ecto.Multi.insert(
            :pending_aggregated_team_stats_by_phase,
            pending_aggregated_team_stats_by_phase_changeset
          )

        case Repo.transaction(multi_team_stats_logs_and_pending_aggregated_team_stats) do
          {:ok, transaction_result} ->
            {:ok,
             transaction_result
             |> Map.drop([:pending_aggregated_team_stats_by_phase])}

          _ ->
            Repo.transaction(multi_team_stats_logs_and_pending_aggregated_team_stats)
        end
    end
  end

  @doc """
  Updates a team_stats_log.

  ## Examples

      iex> update_team_stats_log(team_stats_log, %{field: new_value})
      {:ok, %TeamStatsLog{}}

      iex> update_team_stats_log(team_stats_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team_stats_log(%TeamStatsLog{} = team_stats_log, attrs) do
    team_stats_logs_changeset =
      team_stats_log
      |> TeamStatsLog.changeset(attrs)

    case team_stats_logs_changeset.valid? do
      false ->
        {:error, team_stats_logs_changeset}

      true ->
        pending_aggregated_team_stats_by_phase = %{
          phase_id: team_stats_log.phase_id,
          tournament_id: team_stats_log.tournament_id
        }

        pending_aggregated_team_stats_by_phase_changeset =
          %PendingAggregatedTeamStatsByPhase{}
          |> PendingAggregatedTeamStatsByPhase.changeset(pending_aggregated_team_stats_by_phase)

        {:ok, %{team_stats_logs: team_stats_logs}} =
          Ecto.Multi.new()
          |> Ecto.Multi.update(:team_stats_logs, team_stats_logs_changeset)
          |> Ecto.Multi.insert(
            :pending_aggregated_team_stats_by_phase,
            pending_aggregated_team_stats_by_phase_changeset
          )
          |> Repo.transaction()

        {:ok, team_stats_logs}
    end
  end

  @doc """
  Updates many team stats logs.

  ## Examples

      iex> update_team_stats_logs([%{field: new_value}])
      {:ok, [%TeamStatsLog{}]}

      iex> update_team_stats_logs([%{field: bad_value}])
      {:error, %Ecto.Changeset{}}

  """
  def update_team_stats_logs(team_stats_logs) do
    multi_team_stats_logs =
      team_stats_logs
      |> Enum.reduce(Ecto.Multi.new(), fn team_stats_log, multi ->
        %{"id" => id} = team_stats_log
        current_team_stats_log = Repo.get_by!(TeamStatsLog, id: id)
        changeset = TeamStatsLog.changeset(current_team_stats_log, team_stats_log)

        Ecto.Multi.update(multi, id, changeset)
      end)

    case Enum.count(team_stats_logs) do
      0 ->
        Repo.transaction(multi_team_stats_logs)

      _ ->
        current_team_stats_log = Repo.get_by!(TeamStatsLog, id: List.first(team_stats_logs)["id"])

        pending_aggregated_team_stats_by_phase = %{
          phase_id: current_team_stats_log.phase_id,
          tournament_id: current_team_stats_log.tournament_id
        }

        pending_aggregated_team_stats_by_phase_changeset =
          %PendingAggregatedTeamStatsByPhase{}
          |> PendingAggregatedTeamStatsByPhase.changeset(pending_aggregated_team_stats_by_phase)

        multi_team_stats_logs_and_pending_aggregated_team_stats =
          multi_team_stats_logs
          |> Ecto.Multi.insert(
            :pending_aggregated_team_stats_by_phase,
            pending_aggregated_team_stats_by_phase_changeset
          )

        case Repo.transaction(multi_team_stats_logs_and_pending_aggregated_team_stats) do
          {:ok, transaction_result} ->
            {:ok,
             transaction_result
             |> Map.drop([:pending_aggregated_team_stats_by_phase])}

          _ ->
            Repo.transaction(multi_team_stats_logs_and_pending_aggregated_team_stats)
        end
    end
  end

  @doc """
  Deletes a team_stats_log.

  ## Examples

      iex> delete_team_stats_log(team_stats_log)
      {:ok, %TeamStatsLog{}}

      iex> delete_team_stats_log(team_stats_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team_stats_log(%TeamStatsLog{} = team_stats_log) do
    pending_aggregated_team_stats_by_phase = %{
      phase_id: team_stats_log.phase_id,
      tournament_id: team_stats_log.tournament_id
    }

    pending_aggregated_team_stats_by_phase_changeset =
      %PendingAggregatedTeamStatsByPhase{}
      |> PendingAggregatedTeamStatsByPhase.changeset(pending_aggregated_team_stats_by_phase)

    {:ok, %{team_stats_logs: team_stats_logs}} =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:team_stats_logs, team_stats_log)
      |> Ecto.Multi.insert(
        :pending_aggregated_team_stats_by_phase,
        pending_aggregated_team_stats_by_phase_changeset
      )
      |> Repo.transaction()

    {:ok, team_stats_logs}
  end

  @doc """
  Generates a team_stats_log based on a game

  ## Examples

      iex> generate_team_stats_log("game-id")
      :ok

  """
  @spec generate_team_stats_log(game_id :: Ecto.UUID.t()) :: :ok
  def generate_team_stats_log(game_id) do
    IO.inspect("Generating team stats log for game #{game_id}")
    :ok
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_stats_log changes.

  ## Examples

      iex> change_team_stats_log(team_stats_log)
      %Ecto.Changeset{source: %TeamStatsLog{}}

  """
  def change_team_stats_log(%TeamStatsLog{} = team_stats_log) do
    TeamStatsLog.changeset(team_stats_log, %{})
  end
end
