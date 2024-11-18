defmodule GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor do
  alias GoChampsApi.Infrastructure.Processors.Models.Event
  alias GoChampsApi.Games
  require Logger

  @spec process(message :: String.t()) :: :ok | :error
  def process(message) do
    parsed_event =
      Poison.encode!(message["body"]["event"])
      |> Poison.decode!(as: %Event{})

    case parsed_event do
      %Event{key: "start-game-live-mode", game_id: game_id} -> start_game_live_mode(game_id)
      %Event{key: "end-game-live-mode", game_id: game_id} -> :ok
      _ -> :error
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
end
