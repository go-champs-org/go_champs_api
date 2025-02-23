defmodule GoChampsApi.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.Teams.Team

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id),
    do: Repo.get!(Team, id)

  @doc """
  Gets a single team with preaload data.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team_preload!(123)
      %Team{}

      iex> get_team_preload!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_preload!(id, preload) do
    Repo.get!(Team, id)
    |> Repo.preload(preload)
  end

  @doc """
  Gets a team organization for a given team id..

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_team_organization!(123)
      %Tournament{}

      iex> get_team_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_organization!(id) do
    {:ok, tournament} =
      Repo.get_by!(Team, id: id)
      |> Repo.preload(tournament: :organization)
      |> Map.fetch(:tournament)

    {:ok, organization} =
      tournament
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{source: %Team{}}

  """
  def change_team(%Team{} = team) do
    Team.changeset(team, %{})
  end
end
