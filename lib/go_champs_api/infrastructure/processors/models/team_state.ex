defmodule GoChampsApi.Infrastructure.Processors.Models.TeamState do
  alias GoChampsApi.Infrastructure.Processors.Models.PlayerState

  @type t :: %__MODULE__{
          name: String.t(),
          players: [PlayerState.t()],
          stats_values: map(),
          total_player_stats: map()
        }

  defstruct [:name, :players, :stats_values, :total_player_stats]

  @spec new(String.t(), [PlayerState.t()]) :: t()
  @spec new(String.t(), [PlayerState.t()], map()) :: t()
  @spec new(String.t(), [PlayerState.t()], map(), map()) :: t()
  def new(name, players, stats_values \\ nil, total_player_stats \\ nil) do
    %__MODULE__{
      name: name,
      players: players,
      stats_values: stats_values,
      total_player_stats: total_player_stats
    }
  end
end
