defmodule GoChampsApi.Tournaments do
  @moduledoc """
  The Tournaments context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Sports
  alias GoChampsApi.Repo

  alias GoChampsApi.Tournaments.Tournament

  alias GoChampsApi.PendingAggregatedPlayerStatsByTournaments.PendingAggregatedPlayerStatsByTournament
  alias GoChampsApi.AggregatedPlayerStatsByTournaments.AggregatedPlayerStatsByTournament
  alias GoChampsApi.Players.Player
  alias GoChampsApi.PlayerStatsLogs.PlayerStatsLog
  alias GoChampsApi.RecentlyViews.RecentlyView

  alias GoChampsApi.Organizations.Organization

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
    |> Repo.preload([:organization, :phases, :players, :teams])
  end

  @doc """
  Gets a tournament organization for a given tournament id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_tournament_organization!(123)
      %Tournament{}

      iex> get_tournament_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament_organization!(id) do
    {:ok, organization} =
      Tournament
      |> Repo.get!(id)
      |> Repo.preload([:organization])
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Gets the first player stats log id

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_tournament_default_player_stats_order_id!(123)
      %Tournament{}

      iex> get_tournament_default_player_stats_order_id!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tournament_default_player_stats_order_id!(id) do
    tournament =
      Tournament
      |> Repo.get!(id)

    sport_statistic = Sports.get_default_player_statistic_to_order_by(tournament.sport_slug)

    case sport_statistic do
      nil ->
        tournament.player_stats
        |> Enum.at(0, %{id: 0})
        |> Map.get(:id)

      _ ->
        sport_statistic.slug
    end
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
    aggregated_delete_query =
      from a in AggregatedPlayerStatsByTournament,
        where: a.tournament_id == ^tournament.id

    pending_aggregated_delete_query =
      from p in PendingAggregatedPlayerStatsByTournament,
        where: p.tournament_id == ^tournament.id

    player_delete_query =
      from p in Player,
        where: p.tournament_id == ^tournament.id

    player_stats_logs_delete_query =
      from p in PlayerStatsLog,
        where: p.tournament_id == ^tournament.id

    recently_views_delete_query =
      from p in RecentlyView,
        where: p.tournament_id == ^tournament.id

    {:ok, %{tournament: tournament_result}} =
      Ecto.Multi.new()
      |> Ecto.Multi.delete_all(
        :aggregated_player_stats_by_tournament,
        aggregated_delete_query
      )
      |> Ecto.Multi.delete_all(
        :pending_aggregated_player_stats_by_tournament,
        pending_aggregated_delete_query
      )
      |> Ecto.Multi.delete_all(
        :player_stats_logs,
        player_stats_logs_delete_query
      )
      |> Ecto.Multi.delete_all(
        :players,
        player_delete_query
      )
      |> Ecto.Multi.delete_all(
        :recently_views,
        recently_views_delete_query
      )
      |> Ecto.Multi.delete(:tournament, tournament)
      |> Repo.transaction()

    {:ok, tournament_result}
  end

  @doc """
  Search tournaments.
  """
  def search_tournaments(term) do
    search_term = "%#{term}%"

    Repo.all(
      from t in Tournament,
        join: o in assoc(t, :organization),
        where:
          ilike(t.name, ^search_term) or ilike(t.slug, ^search_term) or
            ilike(o.name, ^search_term) or ilike(o.slug, ^search_term),
        preload: [organization: o]
    )
  end

  @doc """
  Sets has_aggregated_player_stats of the given id tournament to true.
  """
  def set_aggregated_player_stats!(id) do
    tournament =
      Tournament
      |> Repo.get!(id)

    tournament = Ecto.Changeset.change(tournament, has_aggregated_player_stats: true)

    Repo.update(tournament)
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

  @doc """
  Returns a player stat of a tournament for a given player stat id.

  Returns `nil` if the player stat does not exist.

  ## Examples

      iex> get_player_stat_by_id!(%Tournament{}, 123)
      %PlayerStat{}

      iex> get_player_stat_by_id!(%Tournament{}, 456)
      nil
  """
  @spec get_player_stat_by_id!(Tournament.t(), String.t()) :: PlayerStatsLog.t() | nil
  def get_player_stat_by_id!(%Tournament{} = tournament, player_stat_id) do
    tournament.player_stats
    |> Enum.find(&(&1.id == player_stat_id))
  end

  @doc """
  Returns a player stat of a tournament for a given player stat slug.

  Returns `nil` if the player stat does not exist.

  ## Examples

      iex> get_player_stat_by_slug!(%Tournament{}, "slug")
      %PlayerStat{}

      iex> get_player_stat_by_slug!(%Tournament{}, "slug")
      nil
  """
  @spec get_player_stat_by_slug!(Tournament.t(), String.t()) :: PlayerStatsLog.t() | nil
  def get_player_stat_by_slug!(%Tournament{} = tournament, player_stat_slug) do
    tournament.player_stats
    |> Enum.find(&(&1.slug == player_stat_slug))
  end

  @doc """
  Returns a list of player stats keys for a given tournament.
  If player stats has slug it will return the slug, otherwise it will return the id.

  ## Examples

      iex> get_player_stats_keys(%Tournament{})
      ["slug1", "slug2", "slug3"]

  """
  @spec get_player_stats_keys(Tournament.t()) :: [String.t()]
  def get_player_stats_keys(%Tournament{} = tournament) do
    tournament.player_stats
    |> Enum.map(fn stat ->
      stat.slug || stat.id
    end)
  end

  @doc """
  Returns a list of team stats keys for a given tournament.
  If team stats has slug it will return the slug, otherwise it will return the id.

  ## Examples

      iex> get_team_stats_keys(%Tournament{})
      ["slug1", "slug2", "slug3"]

  """
  @spec get_team_stats_keys(Tournament.t()) :: [String.t()]
  def get_team_stats_keys(%Tournament{} = tournament) do
    tournament.team_stats
    |> Enum.map(fn stat ->
      stat.slug || stat.id
    end)
  end
end
