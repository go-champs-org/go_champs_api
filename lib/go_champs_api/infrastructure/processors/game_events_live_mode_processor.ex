defmodule GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor do
  alias GoChampsApi.Infrastructure.Processors.Models.{
    Event,
    GameState,
    TeamState,
    PlayerState
  }

  alias GoChampsApi.Games
  alias GoChampsApi.Phases
  alias GoChampsApi.PlayerStatsLogs
  require Logger

  @spec process(message :: String.t()) :: :ok | :error
  def process(message) do
    try do
      parsed_event =
        Poison.encode!(message["body"]["event"])
        |> Poison.decode!(as: %Event{})

      parsed_game =
        Poison.encode!(message["body"]["game_state"])
        |> Poison.decode!(
          as: %GameState{
            away_team: %TeamState{
              players: [%PlayerState{}]
            },
            home_team: %TeamState{
              players: [%PlayerState{}]
            }
          }
        )

      case parsed_event do
        %Event{key: "start-game-live-mode", game_id: game_id} ->
          start_game_live_mode(game_id)

        %Event{key: "end-game-live-mode", game_id: game_id} ->
          end_game_live_mode(game_id, parsed_game)

        _ ->
          :error
      end
    rescue
      exception ->
        Logger.error("Error processing event: #{inspect(exception)}")
        :error
    end
  end

  defp start_game_live_mode(game_id) do
    Logger.info("Starting live mode for game #{game_id}", game_id: game_id)

    case Games.get_game!(game_id)
         |> Games.update_game(%{live_state: :in_progress}) do
      {:ok, _} -> :ok
      {:error, error} -> :error
    end
  end

  defp end_game_live_mode(game_id, game_state) do
    Logger.info("Ending live mode for game #{game_id}", game_id: game_id)

    case Games.get_game!(game_id)
         |> Games.update_game(%{live_state: :ended}) do
      {:ok, updated_game} ->
        away_team_id = updated_game.away_team_id
        phase_id = updated_game.phase_id
        home_team_id = updated_game.home_team_id
        phase = Phases.get_phase!(phase_id)
        tournament_id = phase.tournament_id

        away_team_player_stats_logs =
          game_state.away_team
          |> map_game_state_to_player_stats_logs(%{
            game_id: game_id,
            phase_id: phase_id,
            team_id: away_team_id,
            tournament_id: tournament_id
          })

        home_team_player_stats_logs =
          game_state.home_team
          |> map_game_state_to_player_stats_logs(%{
            game_id: game_id,
            phase_id: phase_id,
            team_id: home_team_id,
            tournament_id: tournament_id
          })

        {:ok, _} = PlayerStatsLogs.create_player_stats_logs(away_team_player_stats_logs)
        {:ok, _} = PlayerStatsLogs.create_player_stats_logs(home_team_player_stats_logs)
        :ok

      {:error, error} ->
        :error
    end
  end

  defp map_game_state_to_player_stats_logs(team_state, base_player_stats_log) do
    Enum.map(team_state.players, fn %PlayerState{id: id, stats_values: stats_values} ->
      base_player_stats_log
      |> Map.put(:player_id, id)
      |> Map.put(:stats, stats_values)
    end)
  end
end
