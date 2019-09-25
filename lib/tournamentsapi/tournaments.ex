defmodule TournamentsApi.Tournaments do
  @moduledoc """
  The Tournaments context.
  """

  import Ecto.Query, warn: false
  alias TournamentsApi.Repo

  alias TournamentsApi.Tournaments.Tournament
  alias TournamentsApi.Organizations.Organization

  @doc """
  Returns the list of tournaments.

  ## Examples

      iex> list_tournaments()
      [%Tournament{}, ...]

  """
  def list_tournaments do
    Repo.all(Tournament)
  end

  @doc """
  Returns the list of tournaments filter by keywork param.

  ## Examples

      iex> list_tournaments([name: "some name"])
      [%Tournament{}, ...]

  """
  def list_tournaments(where) do
    query = from t in Tournament, where: ^where
    Repo.all(query)
  end

  @doc """
  Gets a single tournament.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_tournament!(123)
      %Tournament{}

      iex> get_tournament!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament!(id) do
    Tournament
    |> Repo.get!(id)
    |> Repo.preload([:organization, :phases, :teams])
  end

  @doc """
  Creates a tournament.

  ## Examples

      iex> create_tournament(%{field: value})
      {:ok, %Tournament{}n

      iex> create_tournament(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament(attrs \\ %{}) do
    %Tournament{}
    |> Tournament.changeset(attrs)
    |> map_organization_slug()
    |> Repo.insert()
  end

  defp map_organization_slug(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true} ->
        organization_id = Ecto.Changeset.get_change(changeset, :organization_id)
        organization = Repo.get(Organization, organization_id)
        Ecto.Changeset.put_change(changeset, :organization_slug, organization.slug)

      _ ->
        changeset
    end
  end

  @doc """
  Updates a tournament.

  ## Examples

      iex> update_tournament(tournament, %{field: new_value})
      {:ok, %Tournament{}}

      iex> update_tournament(tournament, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament(%Tournament{} = tournament, attrs) do
    tournament
    |> Tournament.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tournament.

  ## Examples

      iex> delete_tournament(tournament)
      {:ok, %Tournament{}}

      iex> delete_tournament(tournament)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament(%Tournament{} = tournament) do
    Repo.delete(tournament)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament changes.

  ## Examples

      iex> change_tournament(tournament)
      %Ecto.Changeset{source: %Tournament{}}

  """
  def change_tournament(%Tournament{} = tournament) do
    Tournament.changeset(tournament, %{})
  end

  alias TournamentsApi.Tournaments.TournamentTeam

  @doc """
  Returns the list of tournament_teams.

  ## Examples

      iex> list_tournament_teams()
      [%TournamentTeam{}, ...]

  """
  def list_tournament_teams(tournament_id) do
    Repo.all(TournamentTeam, tournament_id: tournament_id)
  end

  @doc """
  Gets a single tournament_team.

  Raises `Ecto.NoResultsError` if the Tournament team does not exist.

  ## Examples

      iex> get_tournament_team!(123)
      %TournamentTeam{}

      iex> get_tournament_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament_team!(id, tournament_id),
    do: Repo.get_by!(TournamentTeam, id: id, tournament_id: tournament_id)

  @doc """
  Creates a tournament_team.

  ## Examples

      iex> create_tournament_team(%{field: value})
      {:ok, %TournamentTeam{}}

      iex> create_tournament_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament_team(attrs \\ %{}) do
    %TournamentTeam{}
    |> TournamentTeam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tournament_team.

  ## Examples

      iex> update_tournament_team(tournament_team, %{field: new_value})
      {:ok, %TournamentTeam{}}

      iex> update_tournament_team(tournament_team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament_team(%TournamentTeam{} = tournament_team, attrs) do
    tournament_team
    |> TournamentTeam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TournamentTeam.

  ## Examples

      iex> delete_tournament_team(tournament_team)
      {:ok, %TournamentTeam{}}

      iex> delete_tournament_team(tournament_team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament_team(%TournamentTeam{} = tournament_team) do
    Repo.delete(tournament_team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament_team changes.

  ## Examples

      iex> change_tournament_team(tournament_team)
      %Ecto.Changeset{source: %TournamentTeam{}}

  """
  def change_tournament_team(%TournamentTeam{} = tournament_team) do
    TournamentTeam.changeset(tournament_team, %{})
  end

  alias TournamentsApi.Tournaments.TournamentGame

  @doc """
  Returns the list of tournament_games.

  ## Examples

      iex> list_tournament_games()
      [%TournamentGame{}, ...]

  """
  def list_tournament_games(tournament_phase_id) do
    {:ok, uuid} = Ecto.UUID.cast(tournament_phase_id)

    TournamentGame
    |> where([g], g.tournament_phase_id == ^uuid)
    |> Repo.all()
    |> Repo.preload([:away_team, :home_team])
  end

  @doc """
  Gets a single tournament_game.

  Raises `Ecto.NoResultsError` if the Tournament game does not exist.

  ## Examples

      iex> get_tournament_game!(123)
      %TournamentGame{}

      iex> get_tournament_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament_game!(id, tournament_phase_id),
    do:
      Repo.get_by!(TournamentGame, id: id, tournament_phase_id: tournament_phase_id)
      |> Repo.preload([:away_team, :home_team])

  @doc """
  Creates a tournament_game.

  ## Examples

      iex> create_tournament_game(%{field: value})
      {:ok, %TournamentGame{}}

      iex> create_tournament_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament_game(attrs \\ %{}) do
    %TournamentGame{}
    |> TournamentGame.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tournament_game.

  ## Examples

      iex> update_tournament_game(tournament_game, %{field: new_value})
      {:ok, %TournamentGame{}}

      iex> update_tournament_game(tournament_game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament_game(%TournamentGame{} = tournament_game, attrs) do
    tournament_game
    |> TournamentGame.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TournamentGame.

  ## Examples

      iex> delete_tournament_game(tournament_game)
      {:ok, %TournamentGame{}}

      iex> delete_tournament_game(tournament_game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament_game(%TournamentGame{} = tournament_game) do
    Repo.delete(tournament_game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament_game changes.

  ## Examples

      iex> change_tournament_game(tournament_game)
      %Ecto.Changeset{source: %TournamentGame{}}

  """
  def change_tournament_game(%TournamentGame{} = tournament_game) do
    TournamentGame.changeset(tournament_game, %{})
  end

  alias TournamentsApi.Tournaments.TournamentStat

  @doc """
  Returns the list of tournament_stats.

  ## Examples

      iex> list_tournament_stats()
      [%TournamentStat{}, ...]

  """
  def list_tournament_stats(tournament_phase_id) do
    {:ok, uuid} = Ecto.UUID.cast(tournament_phase_id)

    TournamentStat
    |> where([s], s.tournament_phase_id == ^uuid)
    |> Repo.all()
  end

  @doc """
  Gets a single tournament_stat.

  Raises `Ecto.NoResultsError` if the Tournament stat does not exist.

  ## Examples

      iex> get_tournament_stat!(123)
      %TournamentStat{}

      iex> get_tournament_stat!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament_stat!(id, tournament_phase_id),
    do: Repo.get_by!(TournamentStat, id: id, tournament_phase_id: tournament_phase_id)

  @doc """
  Creates a tournament_stat.

  ## Examples

      iex> create_tournament_stat(%{field: value})
      {:ok, %TournamentStat{}}

      iex> create_tournament_stat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament_stat(attrs \\ %{}) do
    %TournamentStat{}
    |> TournamentStat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tournament_stat.

  ## Examples

      iex> update_tournament_stat(tournament_stat, %{field: new_value})
      {:ok, %TournamentStat{}}

      iex> update_tournament_stat(tournament_stat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament_stat(%TournamentStat{} = tournament_stat, attrs) do
    tournament_stat
    |> TournamentStat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TournamentStat.

  ## Examples

      iex> delete_tournament_stat(tournament_stat)
      {:ok, %TournamentStat{}}

      iex> delete_tournament_stat(tournament_stat)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament_stat(%TournamentStat{} = tournament_stat) do
    Repo.delete(tournament_stat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament_stat changes.

  ## Examples

      iex> change_tournament_stat(tournament_stat)
      %Ecto.Changeset{source: %TournamentStat{}}

  """
  def change_tournament_stat(%TournamentStat{} = tournament_stat) do
    TournamentStat.changeset(tournament_stat, %{})
  end

  alias TournamentsApi.Tournaments.TournamentPhase

  @doc """
  Returns the list of tournament_phases.

  ## Examples

      iex> list_tournament_phases()
      [%TournamentPhase{}, ...]

  """
  def list_tournament_phases(tournament_id) do
    {:ok, uuid} = Ecto.UUID.cast(tournament_id)

    TournamentPhase
    |> where([p], p.tournament_id == ^uuid)
    |> Repo.all()
  end

  @doc """
  Gets a single tournament_phase.

  Raises `Ecto.NoResultsError` if the Tournament phase does not exist.

  ## Examples

      iex> get_tournament_phase!(123)
      %TournamentPhase{}

      iex> get_tournament_phase!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament_phase!(id, tournament_id),
    do:
      Repo.get_by!(TournamentPhase, id: id, tournament_id: tournament_id)
      |> Repo.preload([:rounds, :stats, :standings])

  @doc """
  Creates a tournament_phase.

  ## Examples

      iex> create_tournament_phase(%{field: value})
      {:ok, %TournamentPhase{}}

      iex> create_tournament_phase(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tournament_phase(attrs \\ %{}) do
    %TournamentPhase{}
    |> TournamentPhase.changeset(attrs)
    |> get_tournament_phase_next_order()
    |> Repo.insert()
  end

  defp get_tournament_phase_next_order(changeset) do
    tournament_id = Ecto.Changeset.get_field(changeset, :tournament_id)
    number_of_records = Repo.aggregate(TournamentPhase, :count, :id, tournament_id: tournament_id)
    Ecto.Changeset.put_change(changeset, :order, Enum.sum([number_of_records, 1]))
  end

  @doc """
  Updates a tournament_phase.

  ## Examples

      iex> update_tournament_phase(tournament_phase, %{field: new_value})
      {:ok, %TournamentPhase{}}

      iex> update_tournament_phase(tournament_phase, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tournament_phase(%TournamentPhase{} = tournament_phase, attrs) do
    tournament_phase
    |> TournamentPhase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a TournamentPhase.

  ## Examples

      iex> delete_tournament_phase(tournament_phase)
      {:ok, %TournamentPhase{}}

      iex> delete_tournament_phase(tournament_phase)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tournament_phase(%TournamentPhase{} = tournament_phase) do
    Repo.delete(tournament_phase)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tournament_phase changes.

  ## Examples

      iex> change_tournament_phase(tournament_phase)
      %Ecto.Changeset{source: %TournamentPhase{}}

  """
  def change_tournament_phase(%TournamentPhase{} = tournament_phase) do
    TournamentPhase.changeset(tournament_phase, %{})
  end
end
