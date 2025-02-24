defmodule GoChampsApiWeb.IncludeParser do
  @doc """
  Parse a string of comma separated includes into a list of keywords.

  ## Examples

      iex> GoChampsApiWeb.IncludeParser.parse_include_string("registration,registration.tournament,registration_responses")
      [
        registration: [:tournament],
        registration_responses: []
      ]
  """
  @spec parse_include_string(String.t()) :: [keyword()]
  def parse_include_string(include_string) do
    include_string
    |> String.split(",")
    |> Enum.reduce([], &build_nested_structure/2)
  end

  defp build_nested_structure(path, acc) do
    keys = String.split(path, ".")
    insert_nested_keys(keys, acc)
  end

  defp insert_nested_keys([key], acc) do
    Keyword.update(acc, String.to_atom(key), [], & &1)
  end

  defp insert_nested_keys([key | rest], acc) do
    Keyword.update(acc, String.to_atom(key), [], fn nested ->
      insert_nested_keys(rest, nested)
    end)
  end
end
