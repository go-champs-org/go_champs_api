defmodule GoChampsApi.Sports do
  @moduledoc """
  This module contains functions to retrieve sports information.
  """
  alias GoChampsApi.Sports.Sport
  alias GoChampsApi.Sports.Registry

  @spec list_sports() :: [Sport.t()]
  def list_sports() do
    Registry.sports()
  end

  @spec get_sport(String.t()) :: Sport.t() | nil
  def get_sport(slug) do
    Registry.get_sport(slug)
  end

  @doc """
  Returns the list of calculated player statistics for a sport.

  ## Examples

      iex> get_calculated_player_statistics("basketball-5x5")
      [%GoChampsApi.Sports.Statistic{}, ...]
  """
  @spec get_calculated_player_calculated_statistics!(String.t()) :: [
          GoChampsApi.Sports.Statistic.t()
        ]
  def get_calculated_player_calculated_statistics!(slug) do
    try do
      sport = get_sport(slug)

      sport.player_statistics
      |> Enum.filter(fn stat ->
        stat.type == :calculated
      end)
    rescue
      _ -> []
    end
  end
end
