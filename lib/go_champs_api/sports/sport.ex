defmodule GoChampsApi.Sports.Sport do
  alias GoChampsApi.Sports.Statistic

  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t(),
          player_statistics: [Statistic.t()]
        }

  defstruct [:slug, :name, :player_statistics]

  @spec new(String.t(), String.t()) :: t()
  def new(slug, name, player_statistics \\ []) do
    %__MODULE__{
      slug: slug,
      name: name,
      player_statistics: player_statistics
    }
  end
end
