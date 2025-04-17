defmodule GoChampsApi.Sports.Coach do
  @type type :: :head_coach | :assistant_coach

  @type t :: %__MODULE__{
          type: type()
        }

  defstruct [:type]

  @spec new(type :: type()) :: t()
  def new(type) do
    %__MODULE__{
      type: type
    }
  end
end
