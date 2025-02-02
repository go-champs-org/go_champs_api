defmodule GoChampsApi.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.Games.Game
  alias GoChampsApi.Phases
  alias GoChampsApi.Sports

  require Logger

  @doc """
  Returns the list of games filter by keywork param.

  ## Examples

      iex> list_games([name: "some name"])
      [%Tournament{}, ...]

  """
  def list_games(where) do
    query = from t in Game, where: ^where

    Repo.all(query)
    |> Repo.preload([:away_team, :home_team])
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id),
    do:
      Repo.get!(Game, id)
      |> Repo.preload(away_team: :players, home_team: :players)

  @doc """
  Gets a game organization for a given game id.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game_organization("some-id")
      [%Game{}, ...]

  """
  def get_game_organization!(id) do
    {:ok, phase} =
      Repo.get!(Game, id)
      |> Repo.preload([:phase])
      |> Map.fetch(:phase)

    Phases.get_phase_organization!(phase.id)
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Generates game results.

  ## Examples

      iex> generate_results("some-id")
      {:ok, "Game results has been generated for game some-id"}

      iex> generate_results("some-id")
      {:error, "some error"}

  """
  def generate_results(game_id) do
    case Sports.update_game_results(game_id) do
      {:ok, updated_game} ->
        Logger.info("Game results has been generated for game #{game_id}")
        {:ok, "Game results has been generated for game #{game_id}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{source: %Game{}}

  """
  def change_game(%Game{} = game) do
    Game.changeset(game, %{})
  end
end
