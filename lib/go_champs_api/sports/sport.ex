defmodule GoChampsApi.Sports.Sport do
  @type t :: %__MODULE__{
          slug: String.t(),
          name: String.t()
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
