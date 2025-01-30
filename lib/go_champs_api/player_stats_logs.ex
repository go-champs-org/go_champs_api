defmodule GoChampsApi.PlayerStatsLogs do
  @moduledoc """
  The PlayerStatsLogs context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.PlayerStatsLogs.PlayerStatsLog
  alias GoChampsApi.TeamStatsLogs

  alias GoChampsApi.PendingAggregatedPlayerStatsByTournaments.PendingAggregatedPlayerStatsByTournament

  @doc """
  Returns the list of player_stats_log.

  ## Examples

      iex> list_player_stats_log()
      [%PlayerStatsLog{}, ...]

  """
  def list_player_stats_log do
    Repo.all(PlayerStatsLog)
  end

  @doc """
  Returns the list of Player Stats Logs filter by keywork param.

  ## Examples

      iex> list_player_stats_log([game_id: "game-id"])
      [%PlayerStatsLog{}, ...]

  """
  def list_player_stats_log(where) do
    query = from t in PlayerStatsLog, where: ^where
    Repo.all(query)
  end

  @doc """
  Gets a single player_stats_log.

  Raises `Ecto.NoResultsError` if the Player stats log does not exist.

  ## Examples

      iex> get_player_stats_log!(123)
      %PlayerStatsLog{}

      iex> get_player_stats_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player_stats_log!(id), do: Repo.get!(PlayerStatsLog, id)

  @doc """
  Gets a player stats log organization for a given player stats log id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_player_organization!(123)
      %Tournament{}

      iex> get_player_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player_stats_log_organization!(id) do
    {:ok, tournament} =
      Repo.get_by!(PlayerStatsLog, id: id)
      |> Repo.preload(tournament: :organization)
      |> Map.fetch(:tournament)

    {:ok, organization} =
      tournament
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Gets a player_stats_logs tournament id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

  iex> get_player_stats_logs_tournament_id!(123)
  %Tournament{}

  iex> get_player_stats_logs_tournament_id!(456)
  ** (Ecto.NoResultsError)

  """
  def get_player_stats_logs_tournament_id(player_stats_logs) do
    player_stats_logs_id =
      Enum.map(player_stats_logs, fn player_stats_log -> player_stats_log["id"] end)

    case Repo.all(
           from player_stats_log in PlayerStatsLog,
             where: player_stats_log.id in ^player_stats_logs_id,
             group_by: player_stats_log.tournament_id,
             select: player_stats_log.tournament_id
         ) do
      [tournament_id] ->
        {:ok, tournament_id}

      _ ->
        {:error, "Can only update player_stats_log from same tournament"}
    end
  end

  @doc """
  Creates a player_stats_log.

  ## Examples

      iex> create_player_stats_log(%{field: value})
      {:ok, %PlayerStatsLog{}}

      iex> create_player_stats_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player_stats_log(attrs \\ %{}) do
    player_stats_logs_changeset =
      %PlayerStatsLog{}
      |> PlayerStatsLog.changeset(attrs)

    case player_stats_logs_changeset.valid? do
      false ->
        {:error, player_stats_logs_changeset}

      true ->
        pending_aggregated_player_stats_by_tournament = %{
          tournament_id: attrs.tournament_id
        }

        pending_aggregated_player_stats_by_tournament_changeset =
          %PendingAggregatedPlayerStatsByTournament{}
          |> PendingAggregatedPlayerStatsByTournament.changeset(
            pending_aggregated_player_stats_by_tournament
          )

        {:ok, %{player_stats_logs: player_stats_logs}} =
          Ecto.Multi.new()
          |> Ecto.Multi.insert(:player_stats_logs, player_stats_logs_changeset)
          |> Ecto.Multi.insert(
            :pending_aggregated_player_stats_by_tournament,
            pending_aggregated_player_stats_by_tournament_changeset
          )
          |> Repo.transaction()

        start_side_effect_task(player_stats_logs)

        {:ok, player_stats_logs}
    end
  end

  @doc """
  Create many player stats logs.

  ## Examples

      iex> create_player_stats_logs([%{field: new_value}])
      {:ok, [%PlayerStatsLog{}]}

      iex> create_player_stats_logs([%{field: bad_value}])
      {:error, %Ecto.Changeset{}}

  """
  def create_player_stats_logs(player_stats_logs) do
    {multi_player_stats_logs, _} =
      player_stats_logs
      |> Enum.reduce({Ecto.Multi.new(), 0}, fn player_stats_log,
                                               {multi_player_stats_logs, index} ->
        changeset =
          %PlayerStatsLog{}
          |> PlayerStatsLog.changeset(player_stats_log)

        {Ecto.Multi.insert(multi_player_stats_logs, index, changeset), index + 1}
      end)

    case Enum.count(player_stats_logs) do
      0 ->
        Repo.transaction(multi_player_stats_logs)

      _ ->
        first_changeset =
          %PlayerStatsLog{}
          |> PlayerStatsLog.changeset(List.first(player_stats_logs))

        pending_aggregated_player_stats_by_tournament = %{
          tournament_id: Ecto.Changeset.get_change(first_changeset, :tournament_id)
        }

        pending_aggregated_player_stats_by_tournament_changeset =
          %PendingAggregatedPlayerStatsByTournament{}
          |> PendingAggregatedPlayerStatsByTournament.changeset(
            pending_aggregated_player_stats_by_tournament
          )

        multi_player_stats_logs_and_pending_aggregated_player_stats =
          multi_player_stats_logs
          |> Ecto.Multi.insert(
            :pending_aggregated_player_stats_by_tournament,
            pending_aggregated_player_stats_by_tournament_changeset
          )

        case Repo.transaction(multi_player_stats_logs_and_pending_aggregated_player_stats) do
          {:ok, transaction_result} ->
            start_side_effect_task(player_stats_logs)

            {:ok,
             transaction_result
             |> Map.drop([:pending_aggregated_player_stats_by_tournament])}

          _ ->
            Repo.transaction(multi_player_stats_logs_and_pending_aggregated_player_stats)
        end
    end
  end

  @doc """
  Updates a player_stats_log.

  ## Examples

      iex> update_player_stats_log(player_stats_log, %{field: new_value})
      {:ok, %PlayerStatsLog{}}

      iex> update_player_stats_log(player_stats_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player_stats_log(%PlayerStatsLog{} = player_stats_log, attrs) do
    player_stats_logs_changeset =
      player_stats_log
      |> PlayerStatsLog.changeset(attrs)

    case player_stats_logs_changeset.valid? do
      false ->
        {:error, player_stats_logs_changeset}

      true ->
        pending_aggregated_player_stats_by_tournament = %{
          tournament_id: player_stats_log.tournament_id
        }

        pending_aggregated_player_stats_by_tournament_changeset =
          %PendingAggregatedPlayerStatsByTournament{}
          |> PendingAggregatedPlayerStatsByTournament.changeset(
            pending_aggregated_player_stats_by_tournament
          )

        {:ok, %{player_stats_logs: player_stats_logs}} =
          Ecto.Multi.new()
          |> Ecto.Multi.update(:player_stats_logs, player_stats_logs_changeset)
          |> Ecto.Multi.insert(
            :pending_aggregated_player_stats_by_tournament,
            pending_aggregated_player_stats_by_tournament_changeset
          )
          |> Repo.transaction()

        start_side_effect_task(player_stats_logs)

        {:ok, player_stats_logs}
    end
  end

  @doc """
  Updates many player stats logs.

  ## Examples

      iex> update_player_stats_logs([%{field: new_value}])
      {:ok, [%PlayerStatsLog{}]}

      iex> update_player_stats_logs([%{field: bad_value}])
      {:error, %Ecto.Changeset{}}

  """
  def update_player_stats_logs(player_stats_logs) do
    multi_player_stats_logs =
      player_stats_logs
      |> Enum.reduce(Ecto.Multi.new(), fn player_stats_log, multi ->
        %{"id" => id} = player_stats_log
        current_player_stats_log = Repo.get_by!(PlayerStatsLog, id: id)
        changeset = PlayerStatsLog.changeset(current_player_stats_log, player_stats_log)

        Ecto.Multi.update(multi, id, changeset)
      end)

    case Enum.count(player_stats_logs) do
      0 ->
        Repo.transaction(multi_player_stats_logs)

      _ ->
        current_player_stats_log =
          Repo.get_by!(PlayerStatsLog, id: List.first(player_stats_logs)["id"])

        pending_aggregated_player_stats_by_tournament = %{
          tournament_id: current_player_stats_log.tournament_id
        }

        pending_aggregated_player_stats_by_tournament_changeset =
          %PendingAggregatedPlayerStatsByTournament{}
          |> PendingAggregatedPlayerStatsByTournament.changeset(
            pending_aggregated_player_stats_by_tournament
          )

        multi_player_stats_logs_and_pending_aggregated_player_stats =
          multi_player_stats_logs
          |> Ecto.Multi.insert(
            :pending_aggregated_player_stats_by_tournament,
            pending_aggregated_player_stats_by_tournament_changeset
          )

        case Repo.transaction(multi_player_stats_logs_and_pending_aggregated_player_stats) do
          {:ok, transaction_result} ->
            start_side_effect_task(player_stats_logs)

            {:ok,
             transaction_result
             |> Map.drop([:pending_aggregated_player_stats_by_tournament])}

          _ ->
            Repo.transaction(multi_player_stats_logs_and_pending_aggregated_player_stats)
        end
    end
  end

  @doc """
  Deletes a player_stats_log.

  ## Examples

      iex> delete_player_stats_log(player_stats_log)
      {:ok, %PlayerStatsLog{}}

      iex> delete_player_stats_log(player_stats_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player_stats_log(%PlayerStatsLog{} = player_stats_log) do
    pending_aggregated_player_stats_by_tournament = %{
      tournament_id: player_stats_log.tournament_id
    }

    pending_aggregated_player_stats_by_tournament_changeset =
      %PendingAggregatedPlayerStatsByTournament{}
      |> PendingAggregatedPlayerStatsByTournament.changeset(
        pending_aggregated_player_stats_by_tournament
      )

    {:ok, %{player_stats_logs: player_stats_logs}} =
      Ecto.Multi.new()
      |> Ecto.Multi.delete(:player_stats_logs, player_stats_log)
      |> Ecto.Multi.insert(
        :pending_aggregated_player_stats_by_tournament,
        pending_aggregated_player_stats_by_tournament_changeset
      )
      |> Repo.transaction()

    start_side_effect_task(player_stats_logs)

    {:ok, player_stats_logs}
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player_stats_log changes.

  ## Examples

      iex> change_player_stats_log(player_stats_log)
      %Ecto.Changeset{source: %PlayerStatsLog{}}

  """
  def change_player_stats_log(%PlayerStatsLog{} = player_stats_log) do
    PlayerStatsLog.changeset(player_stats_log, %{})
  end

  @doc """
  Start side-effect task to generate results that depend on player stats logs.

  ## Examples

      iex> start_side_effect_tasks(player_stats_logs)
      :ok
  """
  @spec start_side_effect_tasks([%PlayerStatsLog{}]) :: :ok
  def start_side_effect_tasks(player_stats_logs) do
    [player_stats_log | _] = player_stats_logs

    start_side_effect_task(player_stats_log)
  end

  @doc """
  Start side-effect task to generate results that depend on player stats log.

  ## Examples

      iex> start_side_effect_task(player_stats_log)
      :ok
  """
  @spec start_side_effect_task(%PlayerStatsLog{}) :: :ok
  def start_side_effect_task(%PlayerStatsLog{game_id: game_id}) do
    task_supervisor = Application.get_env(:go_champs_api, :task_supervisor)

    IO.inspect(task_supervisor)
    IO.inspect(Task.Supervisor)

    Task.Supervisor.start_child(
      task_supervisor,
      fn ->
        TeamStatsLogs.generate_team_stats_log(game_id)
      end
    )

    # Generate game stats
    :ok
  end

  @spec start_side_effect_task(%PlayerStatsLog{}) :: :ok
  def start_side_effect_task(_) do
    :ok
  end
end
