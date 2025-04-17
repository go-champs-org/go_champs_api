defmodule GoChampsApi.Sports.Sport do
  alias GoChampsApi.Sports.{Statistic, Coach}

  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t(),
          player_statistics: [Statistic.t()],
          team_statistics: [Statistic.t()],
          default_player_statistic_to_order_by: Statistic.t() | nil,
          coach_types: [Coach.t()]
        }

  defstruct [
    :slug,
    :name,
    :player_statistics,
    :team_statistics,
    :default_player_statistic_to_order_by,
    :coach_types
  ]

  @spec new(String.t(), String.t()) :: t()
  @spec new(any(), any(), any()) :: GoChampsApi.Sports.Sport.t()
  def new(
        slug,
        name,
        player_statistics \\ [],
        team_statistics \\ [],
        default_player_statistic_to_order_by \\ nil,
        coach_types \\ []
      ) do
    %__MODULE__{
      slug: slug,
      name: name,
      player_statistics: player_statistics,
      team_statistics: team_statistics,
      default_player_statistic_to_order_by: default_player_statistic_to_order_by,
      coach_types: coach_types
    }
  end
end
