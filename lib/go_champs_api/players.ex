defmodule GoChampsApi.Players do
  @moduledoc """
  The Players context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.Players.Player

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Gets a player organization for a given player id..

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_player_organization!(123)
      %Tournament{}

      iex> get_player_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player_organization!(id) do
    {:ok, tournament} =
      Repo.get_by!(Player, id: id)
      |> Repo.preload(tournament: :organization)
      |> Map.fetch(:tournament)

    {:ok, organization} =
      tournament
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Gets a player or creates a new one.

  ## Examples

      iex> get_player_or_create(%Player{id: 123})
      %Player{}

      iex> get_player_or_create(%Player{id: 456})
      %Player{}
  """
  @spec get_player_or_create(%Player{}) :: %Player{}
  def get_player_or_create(attrs) do
    case Ecto.UUID.cast(attrs.id) do
      {:ok, id} ->
        case Repo.get(Player, id) do
          nil -> attrs |> Map.drop([:id]) |> create_player()
          player -> {:ok, player}
        end

      :error ->
        attrs
        |> Map.drop([:id])
        |> create_player()
    end
  end

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.soft_delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{source: %Player{}}

  """
  def change_player(%Player{} = player) do
    Player.changeset(player, %{})
  end
end
