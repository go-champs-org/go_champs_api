defmodule GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor do
  alias GoChampsApi.Infrastructure.Processors.Models.Event

  @spec process(message :: String.t()) :: :ok | :error
  def process(message) do
    parsed_event =
      Poison.encode!(message["body"]["event"])
      |> Poison.decode!(as: %Event{})

    case parsed_event do
      %Event{key: "start-game-live-mode"} -> :ok
      %Event{key: "end-game-live-mode"} -> :ok
      _ -> :error
    end
  end
end
