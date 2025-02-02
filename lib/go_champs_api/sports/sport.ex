defmodule GoChampsApi.Sports.Sport do
  alias GoChampsApi.Sports.Statistic

  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t(),
          player_statistics: [Statistic.t()],
          team_statistics: [Statistic.t()],
          default_player_statistic_to_order_by: Statistic.t() | nil
        }

  defstruct [
    :slug,
    :name,
    :player_statistics,
    :team_statistics,
    :default_player_statistic_to_order_by
  ]

  @spec new(String.t(), String.t()) :: t()
  @spec new(any(), any(), any()) :: GoChampsApi.Sports.Sport.t()
  def new(
        slug,
        name,
        player_statistics \\ [],
        team_statistics \\ [],
        default_player_statistic_to_order_by \\ nil
      ) do
    %__MODULE__{
      slug: slug,
      name: name,
      player_statistics: player_statistics,
      team_statistics: team_statistics,
      default_player_statistic_to_order_by: default_player_statistic_to_order_by
    }
  end
end
