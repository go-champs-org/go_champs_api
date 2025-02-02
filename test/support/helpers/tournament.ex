defmodule GoChampsApi.Helpers.TournamentHelpers do
  alias GoChampsApi.Helpers.OrganizationHelpers
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Sports

  def map_tournament_id(attrs \\ %{}) do
    {:ok, tournament} =
      %{name: "some tournament", slug: "some-slug"}
      |> OrganizationHelpers.map_organization_id()
      |> Tournaments.create_tournament()

    Map.merge(attrs, %{tournament_id: tournament.id})
  end

  def map_tournament_id_with_other_member(attrs \\ %{}) do
    {:ok, tournament} =
      %{name: "some tournament", slug: "some-slug"}
      |> OrganizationHelpers.map_organization_id_with_other_member()
      |> Tournaments.create_tournament()

    Map.merge(attrs, %{tournament_id: tournament.id})
  end

  def map_tournament_id_with_custom_tournament_attrs(attrs \\ %{}, tournament_attrs \\ %{}) do
    {:ok, tournament} =
      tournament_attrs
      |> Map.put_new(:name, "some tournament")
      |> Map.put_new(:slug, "some-slug")
      |> OrganizationHelpers.map_organization_id()
      |> Tournaments.create_tournament()

    Map.merge(attrs, %{tournament_id: tournament.id})
  end

  def map_tournament_id_and_stat_id(attrs \\ %{}) do
    {:ok, tournament} =
      %{
        name: "some tournament",
        slug: "some-slug",
        player_stats: [
          %{
            title: "some stat"
          }
        ]
      }
      |> OrganizationHelpers.map_organization_id()
      |> Tournaments.create_tournament()

    [player_stat] = tournament.player_stats

    Map.merge(attrs, %{tournament_id: tournament.id, stat_id: player_stat.id})
  end

  def map_tournament_id_and_stat_id_with_other_member(attrs \\ %{}) do
    {:ok, tournament} =
      %{
        name: "some tournament",
        slug: "some-slug",
        player_stats: [
          %{
            title: "some stat"
          }
        ]
      }
      |> OrganizationHelpers.map_organization_id_with_other_member()
      |> Tournaments.create_tournament()

    [player_stat] = tournament.player_stats

    Map.merge(attrs, %{tournament_id: tournament.id, stat_id: player_stat.id})
  end

  def create_simple_tournament(attrs \\ %{}) do
    %{name: "Simple Tournament", slug: "simple-tournament"}
    |> Map.merge(attrs)
    |> OrganizationHelpers.map_organization_id()
    |> Tournaments.create_tournament()
  end

  def create_tournament_basketball_5x5(attrs \\ %{}) do
    basketball_slug = "basketball_5x5"

    sport =
      basketball_slug
      |> Sports.get_sport()

    %{name: "Basketball 5x5", slug: "basketball-5x5", sport_slug: basketball_slug}
    |> Map.merge(attrs)
    |> Map.put_new(
      :player_stats,
      Enum.map(sport.player_statistics, fn stat ->
        %{title: stat.name, slug: stat.slug}
      end)
    )
    |> Map.put_new(
      :team_stats,
      Enum.map(sport.team_statistics, fn stat ->
        %{title: stat.name, slug: stat.slug}
      end)
    )
    |> OrganizationHelpers.map_organization_id()
    |> Tournaments.create_tournament()
  end
end
