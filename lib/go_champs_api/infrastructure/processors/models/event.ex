defmodule GoChampsApi.Infrastructure.Processors.Models.Event do
  @type t :: %__MODULE__{
          key: String.t(),
          timestamp: DateTime.t(),
          payload: any()
        }

  defstruct [:key, :timestamp, :payload]

  @spec new(String.t(), DateTime.t()) :: t()
  @spec new(String.t(), DateTime.t(), any()) :: t()
  def new(key, timestamp, payload \\ nil) do
    %__MODULE__{
      key: key,
      timestamp: timestamp,
      payload: payload
    }
  end
end
