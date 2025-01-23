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
  Returns the list of calculated game statistics for a sport.

  ## Examples

      iex> get_game_level_calculated_statistics("basketball-5x5")
      [%GoChampsApi.Sports.Statistic{}, ...]
  """
  @spec get_game_level_calculated_statistics!(String.t()) :: [
          GoChampsApi.Sports.Statistic.t()
        ]
  def get_game_level_calculated_statistics!(slug) do
    try do
      sport = get_sport(slug)

      sport.player_statistics
      |> Enum.filter(fn stat ->
        stat.level == :game and stat.value_type == :calculated
      end)
    rescue
      _ -> []
    end
  end

  @doc """
  Returns the list of calculated player statistics for a sport.

  ## Examples

      iex> get_calculated_player_statistics("basketball-5x5")
      [%GoChampsApi.Sports.Statistic{}, ...]
  """
  @spec get_tournament_level_per_game_statistics!(String.t()) :: [
          GoChampsApi.Sports.Statistic.t()
        ]
  def get_tournament_level_per_game_statistics!(slug) do
    try do
      sport = get_sport(slug)

      sport.player_statistics
      |> Enum.filter(fn stat ->
        stat.level == :tournament and stat.scope == :per_game
      end)
    rescue
      _ -> []
    end
  end
end
