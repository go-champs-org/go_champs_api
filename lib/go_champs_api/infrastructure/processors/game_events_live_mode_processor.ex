defmodule GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor do
  alias GoChampsApi.Infrastructure.Processors.Models.Event
  alias GoChampsApi.Games
  require Logger

  @spec process(message :: String.t()) :: :ok | :error
  def process(message) do
    try do
      parsed_event =
        Poison.encode!(message["body"]["event"])
        |> Poison.decode!(as: %Event{})

      case parsed_event do
        %Event{key: "start-game-live-mode", game_id: game_id} -> start_game_live_mode(game_id)
        %Event{key: "end-game-live-mode", game_id: game_id} -> end_game_live_mode(game_id)
        _ -> :error
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

  defp end_game_live_mode(game_id) do
    Logger.info("Ending live mode for game #{game_id}", game_id: game_id)

    case Games.get_game!(game_id)
         |> Games.update_game(%{live_state: :ended}) do
      {:ok, _} -> :ok
      {:error, error} -> :error
    end
  end
end