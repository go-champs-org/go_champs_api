defmodule GoChampsApi.Sports.Sport do
  alias GoChampsApi.Sports.Statistic

  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t(),
          player_log_statistics: [Statistic.t()],
          player_tournament_statistics: [Statistic.t()],
          team_log_statistics: [Statistic.t()],
          team_tournament_statistics: [Statistic.t()]
        }

  defstruct [:slug, :name]

  @spec new(String.t(), String.t()) :: t()
  def new(slug, name) do
    %__MODULE__{
      slug: slug,
      name: name
    }
  end
end
