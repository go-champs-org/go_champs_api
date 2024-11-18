defmodule GoChampsApi.Infrastructure.Processors.Models.Event do
  @type t :: %__MODULE__{
          key: String.t(),
          game_id: String.t(),
          timestamp: DateTime.t(),
          payload: any()
        }

  defstruct [:key, :game_id, :timestamp, :payload]

  @spec new(String.t(), String.t(), DateTime.t()) :: t()
  @spec new(String.t(), String.t(), DateTime.t(), any()) :: t()
  def new(key, game_id, timestamp, payload \\ nil) do
    %__MODULE__{
      key: key,
      game_id: game_id,
      timestamp: timestamp,
      payload: payload
    }
  end
end
