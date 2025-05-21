defmodule GoChampsApi.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.Games.Game
  alias GoChampsApi.Phases
  alias GoChampsApi.Sports
  alias GoChampsApi.Tournaments

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
      |> Repo.preload(phase: :tournament, away_team: :players, home_team: :players)

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
  Gets a ScoreboardSetting for a given game id.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game_scoreboard_setting("some-id")
      %ScoreboardSetting{}

  """
  def get_game_scoreboard_setting!(id) do
    {:ok, phase} =
      Repo.get!(Game, id)
      |> Repo.preload([:phase])
      |> Map.fetch(:phase)

    Tournaments.get_tournament_scoreboard_setting!(phase.tournament_id)
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
    case %Game{}
         |> Game.changeset(attrs)
         |> Repo.insert() do
      {:ok, game} ->
        start_side_effect_tasks(game)
        {:ok, game}

      {:error, changeset} ->
        {:error, changeset}
    end
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
    case game
         |> Game.changeset(attrs)
         |> Repo.update() do
      {:ok, updated_game} ->
        start_side_effect_tasks(updated_game)
        {:ok, updated_game}

      {:error, changeset} ->
        {:error, changeset}
    end
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
    case Repo.delete(game) do
      {:ok, _deleted_game} ->
        start_side_effect_tasks(game)
        {:ok, game}

      {:error, changeset} ->
        {:error, changeset}
    end
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
      {:ok, _updated_game} ->
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

  @doc """
  Start side-effect task to generate results that depend on game.
  ## Examples
      iex> start_side_effect_tasks(game)
      :ok
  """
  @spec start_side_effect_tasks(%Game{}) :: :ok
  def start_side_effect_tasks(%Game{phase_id: phase_id, live_state: live_state}) do
    %{phase_id: phase_id}
    |> GoChampsApi.Infrastructure.Jobs.GeneratePhaseResults.new()
    |> Oban.insert()

    if live_state in [:ended, :in_progress] do
      tournament_id =
        Phases.get_phase!(phase_id)
        |> Map.get(:tournament_id)

      %{tournament_id: tournament_id}
      |> GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate.new()
      |> Oban.insert()
    end

    # Generate game stats
    :ok
  end
end
