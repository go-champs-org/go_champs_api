defmodule GoChampsApi.Sports.Statistic do
  @type calculation_function() :: (map() -> float()) | nil

  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t(),
          calculation_function: calculation_function()
        }

  defstruct [:slug, :name, :calculation_function]

  @spec new(String.t(), String.t(), calculation_function()) :: t()
  def new(slug, name, calculation_function \\ nil) do
    %__MODULE__{
      slug: slug,
      name: name,
      calculation_function: calculation_function
    }
  end
end
