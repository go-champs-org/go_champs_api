defmodule GoChampsApi.Infrastructure.Processors.Models.PlayerState do
  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          number: String.t(),
          stats_values: map()
        }

  defstruct [:id, :name, :number, :stats_values]

  @spec new(String.t(), String.t(), String.t()) :: t()
  @spec new(String.t(), String.t(), String.t(), map()) :: t()
  def new(id, name, number, stats_values \\ nil) do
    %__MODULE__{
      id: id,
      name: name,
      number: number,
      stats_values: stats_values
    }
  end
end
