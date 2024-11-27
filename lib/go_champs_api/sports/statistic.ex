defmodule GoChampsApi.Sports.Statistic do
  @type calculation_function() :: (map() -> float()) | nil
  @type type :: :logged | :calculated

  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t(),
          type: type(),
          calculation_function: calculation_function()
        }

  defstruct [:slug, :name, :type, :calculation_function]

  @spec new(String.t(), String.t(), type(), calculation_function()) :: t()
  def new(slug, name, type, calculation_function \\ nil) do
    %__MODULE__{
      slug: slug,
      name: name,
      type: type,
      calculation_function: calculation_function
    }
  end
end
