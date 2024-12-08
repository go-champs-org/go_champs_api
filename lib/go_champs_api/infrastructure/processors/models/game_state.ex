defmodule GoChampsApi.Infrastructure.Processors.Models.GameState do
  alias GoChampsApi.Infrastructure.Processors.Models.TeamState

  @type t :: %__MODULE__{
          id: String.t(),
          home_team: TeamState.t(),
          away_team: TeamState.t()
        }

  defstruct [:id, :home_team, :away_team]

  @spec new(String.t(), TeamState.t(), GoChampsApi.Infrastructure.Processors.Models.TeamState.t()) ::
          t()
  def new(id, home_team, away_team) do
    %__MODULE__{
      id: id,
      home_team: home_team,
      away_team: away_team
    }
  end
end
