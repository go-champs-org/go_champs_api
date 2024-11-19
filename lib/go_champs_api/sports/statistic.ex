defmodule GoChampsApi.Sports.Statistic do
  @type calculation_function() :: (map() -> float()) | nil

  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t(),
          calculation_function: calculation_function()
        }

  defstruct [:slug, :name, :calculation_function]

  @spec new(String.t(), type(), calculation_function()) :: t()
  def new(slug, type, calculation_function \\ nil) do
    %__MODULE__{
      slug: slug,
      type: type,
      calculation_function: calculation_function
    }
  end
end
