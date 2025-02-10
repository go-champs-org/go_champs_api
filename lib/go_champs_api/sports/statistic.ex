defmodule GoChampsApi.Sports.Statistic do
  @type calculation_function() :: (map() -> float()) | (map(), map() -> float()) | nil
  @type value_type :: :manual | :calculated
  @type level :: :game | :game_against_team | :tournament
  @type scope :: :per_game | :aggregate

  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t(),
          value_type: value_type(),
          level: level(),
          scope: scope(),
          calculation_function: calculation_function()
        }

  defstruct [:slug, :name, :value_type, :level, :scope, :calculation_function]

  @spec new(String.t(), String.t(), value_type(), level(), scope(), calculation_function()) :: t()
  def new(slug, name, value_type, level, scope, calculation_function \\ nil) do
    %__MODULE__{
      slug: slug,
      name: name,
      value_type: value_type,
      level: level,
      scope: scope,
      calculation_function: calculation_function
    }
  end
end
