defmodule GoChampsApi.Tournaments do
  @moduledoc """
  The Tournaments context.
  """

  import Ecto.Query, warn: false
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

    case Enum.count(tournament.player_stats) do
      0 -> 0
      _ -> Enum.at(tournament.player_stats, 0).id
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
  Find player stat by player stat slug.

  ## Examples

      iex> find_player_stat_by_slug("some-slug")
      %PlayerStatsLog{}

  """
  @spec find_player_stat_by_slug(%Tournament{}, String.t()) :: %PlayerStatsLog{}
  def find_player_stat_by_slug(tournament, slug) do
    tournament.player_stats
    |> Enum.find(& &1.slug == slug)
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
end
