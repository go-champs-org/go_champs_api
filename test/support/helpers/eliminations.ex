defmodule GoChampsApi.Helpers.EliminationsHelpers do
  alias GoChampsApi.Eliminations

  def create_elimination(attrs \\ %{}) do
    elimination_attrs =
      %{
        title: "some title",
        info: "some info"
      }
      |> Map.merge(attrs)

    {:ok, elimination} = Eliminations.create_elimination(elimination_attrs)

    elimination
  end
end
