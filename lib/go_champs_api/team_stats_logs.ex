defmodule GoChampsApi.TeamStatsLogs do
  @moduledoc """
  The TeamStatsLogs context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.TeamStatsLogs.TeamStatsLog
  alias GoChampsApi.Games.Game
  alias GoChampsApi.PlayerStatsLogs
  alias GoChampsApi.Sports
  alias GoChampsApi.Tournaments
  alias GoChampsApi.PendingAggregatedTeamStatsByPhases.PendingAggregatedTeamStatsByPhase

  require Logger

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
    query = from t in TeamStatsLog, where: ^build_where_clause(where)
    Repo.all(query)
  end

  defp build_where_clause(where) do
    Enum.reduce(where, dynamic(true), fn
      {:phase_id, nil}, dynamic ->
        dynamic([t], ^dynamic and is_nil(t.phase_id))

      {:team_id, nil}, dynamic ->
        dynamic([t], ^dynamic and is_nil(t.team_id))

      {field, value}, dynamic ->
        dynamic([t], ^dynamic and field(t, ^field) == ^value)
    end)
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

        start_side_effect_tasks(team_stats_logs)

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
            first_team_stat_log = Map.get(transaction_result, 0)
            start_side_effect_tasks(first_team_stat_log)

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

        start_side_effect_tasks(team_stats_logs)
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
            first_team_stat_id = List.first(MapSet.to_list(multi_team_stats_logs.names))
            first_team_stat = Map.get(transaction_result, first_team_stat_id)
            start_side_effect_tasks(first_team_stat)

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

    start_side_effect_tasks(team_stats_logs)

    {:ok, team_stats_logs}
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

  @spec generate_team_stats_log_from_game_id(game_id :: String.t()) :: :ok | :error
  def generate_team_stats_log_from_game_id(game_id) do
    Logger.info("Generating team stats log from game id: #{game_id}")

    case Repo.get!(Game, game_id)
         |> Repo.preload(phase: :tournament) do
      nil ->
        :error

      game ->
        base_team_stats_log = %{
          game_id: game_id,
          phase_id: game.phase_id,
          tournament_id: game.phase.tournament_id
        }

        base_team_stats_log
        |> map_stats_and_team_id(game, game.home_team_id)
        |> upsert_team_stats_log()

        base_team_stats_log
        |> map_stats_and_team_id(game, game.away_team_id)
        |> upsert_team_stats_log()

        :ok
    end
  end

  @spec map_stats_and_team_id(base_attrs :: %{}, %Game{}, team_id :: String.t()) :: %{}
  def map_stats_and_team_id(base_attrs, game, team_id) do
    case PlayerStatsLogs.list_player_stats_log(game_id: game.id, team_id: team_id) do
      [] ->
        Map.merge(base_attrs, %{team_id: team_id})

      player_stats_logs ->
        stats =
          player_stats_logs
          |> PlayerStatsLogs.aggregate_and_calculate_player_stats_from_player_stats_logs()

        Map.merge(base_attrs, %{team_id: team_id, stats: stats})
    end
  end

  @spec upsert_team_stats_log(%{}) :: :ok | :error
  def upsert_team_stats_log(attrs) do
    case list_team_stats_log(game_id: attrs.game_id, team_id: attrs.team_id) do
      [] ->
        create_team_stats_log(attrs)

      [team_stats_log] ->
        update_team_stats_log(team_stats_log, attrs)
    end
  end

  @doc """
  Start side-effect task to generate results that depend on team stats log.
  ## Examples
      iex> start_side_effect_tasks(team_stats_log)
      :ok
  """
  @spec start_side_effect_tasks(%TeamStatsLog{}) :: :ok
  def start_side_effect_tasks(%TeamStatsLog{game_id: game_id}) do
    %{game_id: game_id}
    |> GoChampsApi.Infrastructure.Jobs.GenerateGameResults.new()
    |> Oban.insert()

    # Generate game stats
    :ok
  end
end
