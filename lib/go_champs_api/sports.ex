defmodule GoChampsApi.Sports do
  @moduledoc """
  This module contains functions to retrieve sports information.
  """
  alias GoChampsApi.Sports.Basketball5x5.Basketball5x5
  alias GoChampsApi.Games.Game
  alias GoChampsApi.Repo
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
  Returns the default player statistic to order by for a sport.

  ## Examples

      iex> get_default_player_statistic_to_order_by("basketball-5x5")
      %GoChampsApi.Sports.Statistic{}
  """
  @spec get_default_player_statistic_to_order_by(String.t()) ::
          GoChampsApi.Sports.Statistic.t() | nil
  def get_default_player_statistic_to_order_by(slug) do
    try do
      sport = get_sport(slug)
      sport.default_player_statistic_to_order_by
    rescue
      _ -> nil
    end
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

  @doc """
  Returns {:ok, updated_game} for a given game_id if generated results successfully, otherwise {:error, reason}.
  When no sport is found, it returns {:ok, %Game{}} the game without updating it.

  ## Examples

      iex> update_game_results("some-game-id")
      {:ok, %Game{}} | {:error, any()}

  """
  @spec update_game_results(String.t()) ::
          {:ok, %GoChampsApi.Games.Game{}} | {:error, any()}
  def update_game_results(game_id) do
    case Repo.get!(Game, game_id)
         |> Repo.preload(phase: :tournament) do
      game ->
        try do
          game.phase.tournament.sport_slug
          |> update_game_result_for_sport(game)
        rescue
          _ -> {:ok, game}
        end

      _ ->
        {:error, "Game not found"}
    end
  end

  @spec update_game_result_for_sport(String.t(), Game.t()) :: {:ok, Game.t()}
  defp update_game_result_for_sport("basketball_5x5", game) do
    Basketball5x5.update_game_results(game)
  end

  @spec update_game_result_for_sport(String.t(), Game.t()) :: {:ok, Game.t()}
  defp update_game_result_for_sport(_, game) do
    {:ok, game}
  end
end
