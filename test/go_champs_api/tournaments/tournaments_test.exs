defmodule GoChampsApi.TournamentsTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.Helpers.OrganizationHelpers
  alias GoChampsApi.Tournaments
  alias GoChampsApi.PendingAggregatedPlayerStatsByTournaments
  alias GoChampsApi.Helpers.PlayerHelpers
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Players
  alias GoChampsApi.AggregatedPlayerStatsByTournaments
  alias GoChampsApi.PlayerStatsLogs
  alias GoChampsApi.Organizations
  alias GoChampsApi.RecentlyViews

  describe "tournaments" do
    alias GoChampsApi.Tournaments.Tournament

    @valid_attrs %{
      name: "some name",
      slug: "some-slug",
      facebook: "facebook",
      instagram: "instagram",
      site_url: "site url",
      twitter: "twitter",
      player_stats: [
        %{
          title: "fixed stat",
          slug: "fixed_stat_1"
        },
        %{
          title: "sum stat",
          slug: "fixed_stat_2"
        },
        %{
          title: "average stat"
        }
      ],
      team_stats: [
        %{
          title: "team fixed stat",
          is_default_order: true,
          slug: "team_fixed_stat"
        },
        %{
          title: "team source stat",
          source: "player-stat-id",
          slug: "team_source_stat"
        },
        %{
          title: "team stat"
        }
      ],
      sport_slug: "basketball_5x5",
      sport_name: "Basketball 5x5"
    }
    @update_attrs %{
      name: "some updated name",
      slug: "some-updated-slug",
      facebook: "facebook updated",
      instagram: "instagram updated",
      site_url: "site url updated",
      twitter: "twitter updated"
    }
    @invalid_attrs %{name: nil}

    def tournament_fixture(attrs \\ %{}) do
      {:ok, tournament} =
        attrs
        |> Enum.into(@valid_attrs)
        |> OrganizationHelpers.map_organization_id()
        |> Tournaments.create_tournament()

      tournament
    end

    def map_tournament_team({:ok, tournament}) do
      %{name: "some team name", tournament_id: tournament.id}
    end

    test "list_tournaments/0 returns all tournaments" do
      tournament = tournament_fixture()

      [result_tournament] = Tournaments.list_tournaments()
      assert result_tournament.id == tournament.id
      assert result_tournament.name == tournament.name
      assert result_tournament.slug == tournament.slug
    end

    test "list_tournaments/1 returns all tournaments pertaining to some organization" do
      {:ok, another_organization} =
        Organizations.create_organization(%{name: "another organization", slug: "another-slug"})

      @valid_attrs
      |> Map.merge(%{organization_id: another_organization.id})
      |> Tournaments.create_tournament()

      second_tournament = tournament_fixture()
      where = [organization_id: second_tournament.organization_id]

      [result_tournament] = Tournaments.list_tournaments(where)
      assert result_tournament.id == second_tournament.id
      assert result_tournament.name == second_tournament.name
      assert result_tournament.slug == second_tournament.slug
    end

    test "get_tournament!/1 returns the tournament with given id" do
      tournament = tournament_fixture()
      assert Tournaments.get_tournament!(tournament.id).id == tournament.id
    end

    test "get_tournament_organization!/1 returns the organization with a give tournament id" do
      tournament = tournament_fixture()
      organization = Tournaments.get_tournament_organization!(tournament.id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "get_tournament_default_player_stats_order_id!/1 returns the first player stats id when tournament has no known sport" do
      tournament = tournament_fixture(%{sport_slug: nil})

      assert Tournaments.get_tournament_default_player_stats_order_id!(tournament.id) ==
               Enum.at(tournament.player_stats, 0).id
    end

    test "get_tournament_default_player_stats_order_id!/1 returns points when tournament is basketball" do
      tournament = tournament_fixture()

      assert Tournaments.get_tournament_default_player_stats_order_id!(tournament.id) == "points"
    end

    test "get_tournament_default_player_stats_order_id!/1 returns 0 when tournament is unknown sport and tournament has not player_stats" do
      tournament = tournament_fixture(%{sport_slug: nil, player_stats: []})

      assert Tournaments.get_tournament_default_player_stats_order_id!(tournament.id) == 0
    end

    test "create_tournament/1 with valid data creates a tournament" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_attrs)

      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)
      assert tournament.name == "some name"
      assert tournament.slug == "some-slug"
      assert tournament.facebook == "facebook"
      assert tournament.instagram == "instagram"
      assert tournament.site_url == "site url"
      assert tournament.twitter == "twitter"
      assert tournament.sport_slug == "basketball_5x5"
      assert tournament.sport_name == "Basketball 5x5"
      assert tournament.visibility == "public"

      [fixed_stat, sum_stat, average_stat] = tournament.player_stats

      assert fixed_stat.id != sum_stat.id
      assert fixed_stat.title == "fixed stat"
      assert fixed_stat.slug == "fixed_stat_1"
      assert sum_stat.title == "sum stat"
      assert sum_stat.slug == "fixed_stat_2"
      assert average_stat.title == "average stat"
      assert average_stat.slug == nil

      [fixed_team_stat, fixed_source_stat, team_stat] = tournament.team_stats

      assert fixed_team_stat.title == "team fixed stat"
      assert fixed_team_stat.is_default_order == true
      assert fixed_team_stat.slug == "team_fixed_stat"
      assert fixed_source_stat.title == "team source stat"
      assert fixed_source_stat.source == "player-stat-id"
      assert fixed_source_stat.slug == "team_source_stat"
      assert team_stat.title == "team stat"
      assert team_stat.slug == nil
    end

    test "create_tournament/1 with nil sport slug creates a tournament" do
      attrs = %{@valid_attrs | sport_slug: nil, sport_name: "Basketball"}
      valid_tournament = OrganizationHelpers.map_organization_id(attrs)

      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      assert tournament.sport_slug == nil
      assert tournament.sport_name == "Basketball"
    end

    test "create_tournament/1 with private visibility creates a tournament" do
      attrs = Map.put(@valid_attrs, :visibility, "private")
      valid_tournament = OrganizationHelpers.map_organization_id(attrs)

      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      assert tournament.visibility == "private"
    end

    test "create_tournament/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tournaments.create_tournament(@invalid_attrs)
    end

    test "create_tournament/1 with invalid slug returns error changeset" do
      invalid_attrs = %{name: "some name", slug: "Some Slug"}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Tournaments.create_tournament(invalid_attrs)

      assert changeset.errors[:slug] == {"has invalid format", [validation: :format]}
    end

    test "create_tournament/1 with repeated slug returns error changeset" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_attrs)
      Tournaments.create_tournament(valid_tournament)

      assert {:error, changeset} = Tournaments.create_tournament(valid_tournament)

      assert changeset.errors[:slug] ==
               {"has already been taken",
                [constraint: :unique, constraint_name: "tournaments_slug_organization_id_index"]}
    end

    test "create_tournament/1 with invalid sport slug returns error changeset" do
      invalid_attrs = %{@valid_attrs | sport_slug: "invalid_sport"}

      assert {:error, %Ecto.Changeset{} = changeset} =
               Tournaments.create_tournament(invalid_attrs)

      assert changeset.errors[:sport_slug] ==
               {"is invalid", [{:validation, :inclusion}, {:enum, ["basketball_5x5"]}]}
    end

    test "create_tournament/1 with invalid visibility returns error changeset" do
      invalid_attrs = Map.put(@valid_attrs, :visibility, "invalid")

      assert {:error, %Ecto.Changeset{} = changeset} =
               Tournaments.create_tournament(invalid_attrs)

      assert changeset.errors[:visibility] ==
               {"is invalid", [{:validation, :inclusion}, {:enum, ["public", "private"]}]}
    end

    test "update_tournament/2 with valid data updates the tournament" do
      tournament = tournament_fixture()

      assert {:ok, %Tournament{} = tournament} =
               Tournaments.update_tournament(tournament, @update_attrs)

      assert tournament.name == "some updated name"
      assert tournament.slug == "some-updated-slug"
      assert tournament.facebook == "facebook updated"
      assert tournament.instagram == "instagram updated"
      assert tournament.site_url == "site url updated"
      assert tournament.twitter == "twitter updated"
    end

    test "update_tournament/2 with invalid data returns error changeset" do
      tournament = tournament_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Tournaments.update_tournament(tournament, @invalid_attrs)

      assert tournament.id == Tournaments.get_tournament!(tournament.id).id
    end

    test "delete_tournament/1 deletes the tournament" do
      tournament = tournament_fixture()
      assert {:ok, %Tournament{}} = Tournaments.delete_tournament(tournament)
      assert_raise Ecto.NoResultsError, fn -> Tournaments.get_tournament!(tournament.id) end
    end

    test "delete_tournament/1 deletes the tournament and associated players" do
      {:ok, player} =
        %{name: "player name"}
        |> TournamentHelpers.map_tournament_id()
        |> Players.create_player()

      tournament = Tournaments.get_tournament!(player.tournament_id)

      assert {:ok, %Tournament{}} = Tournaments.delete_tournament(tournament)
      assert Players.list_players() == []
    end

    test "delete_tournament/1 deletes the tournament and associated player_stats_logs" do
      {:ok, player_stats_log} =
        %{stats: %{"some" => "some"}}
        |> PlayerHelpers.map_player_id_and_tournament_id()
        |> PlayerStatsLogs.create_player_stats_log()

      tournament = Tournaments.get_tournament!(player_stats_log.tournament_id)

      assert {:ok, %Tournament{}} = Tournaments.delete_tournament(tournament)
      assert PlayerStatsLogs.list_player_stats_log() == []
    end

    test "delete_tournament/1 deletes the tournament and associated pending_aggregated_player_stats_by_tournament" do
      tournament = tournament_fixture()

      %{tournament_id: tournament.id}
      |> PendingAggregatedPlayerStatsByTournaments.create_pending_aggregated_player_stats_by_tournament()

      assert {:ok, %Tournament{}} = Tournaments.delete_tournament(tournament)
      assert PendingAggregatedPlayerStatsByTournaments.list_tournament_ids() == []
    end

    test "delete_tournament/1 deletes the tournament and associated aggregated_player_stats_by_tournament" do
      {:ok, aggregated_player_stats_by_tournament} =
        %{stats: %{"some" => "some"}}
        |> PlayerHelpers.map_player_id_and_tournament_id()
        |> AggregatedPlayerStatsByTournaments.create_aggregated_player_stats_by_tournament()

      tournament =
        Tournaments.get_tournament!(aggregated_player_stats_by_tournament.tournament_id)

      assert {:ok, %Tournament{}} = Tournaments.delete_tournament(tournament)
      assert AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament() == []
    end

    test "delete_tournament/1 deletes the tournament and associated recently_view" do
      tournament = tournament_fixture()

      %{tournament_id: tournament.id}
      |> RecentlyViews.create_recently_view()

      assert {:ok, %Tournament{}} = Tournaments.delete_tournament(tournament)
      assert RecentlyViews.list_recently_view() == []
    end

    test "change_tournament/1 returns a tournament changeset" do
      tournament = tournament_fixture()
      assert %Ecto.Changeset{} = Tournaments.change_tournament(tournament)
    end

    test "search_tournaments/1 returns all tournaments matching common term" do
      {:ok, another_organization} =
        Organizations.create_organization(%{name: "another organization", slug: "another-slug"})

      {:ok, first_tournament} =
        %{name: "another name", slug: "some-slug"}
        |> Map.merge(%{organization_id: another_organization.id})
        |> Tournaments.create_tournament()

      second_tournament = tournament_fixture()

      term = "name"

      [first_result, second_result] = Tournaments.search_tournaments(term)

      assert first_result.id == first_tournament.id
      assert second_result.id == second_tournament.id
    end

    test "search_tournaments/1 returns all tournaments matching second tournament term" do
      {:ok, another_organization} =
        Organizations.create_organization(%{name: "another organization", slug: "another-slug"})

      {:ok, first_tournament} =
        %{name: "another name", slug: "another-slug"}
        |> Map.merge(%{organization_id: another_organization.id})
        |> Tournaments.create_tournament()

      tournament_fixture()

      term = "another"

      [first_result] = Tournaments.search_tournaments(term)

      assert first_result.id == first_tournament.id
    end

    test "set_aggregated_player_stats/1 updates to true the aggregated_player_stats property" do
      tournament = tournament_fixture()

      tournament_before = Tournaments.get_tournament!(tournament.id)
      assert tournament_before.has_aggregated_player_stats == false

      Tournaments.set_aggregated_player_stats!(tournament.id)

      tournament_after = Tournaments.get_tournament!(tournament.id)
      assert tournament_after.has_aggregated_player_stats == true
    end

    test "get_player_stat_by_id!/2 returns the player stats with the given id" do
      tournament = tournament_fixture()

      player_stat = Enum.at(tournament.player_stats, 0)
      assert Tournaments.get_player_stat_by_id!(tournament, player_stat.id) == player_stat
    end

    test "get_player_stat_by_id!/2 returns nil if the player stats does not exist" do
      tournament = tournament_fixture()

      assert Tournaments.get_player_stat_by_id!(tournament, 123) == nil
    end

    test "get_player_stat_by_slug!/2 returns the player stats with the given slug" do
      tournament = tournament_fixture()

      player_stat = Enum.at(tournament.player_stats, 0)
      assert Tournaments.get_player_stat_by_slug!(tournament, player_stat.slug) == player_stat
    end

    test "get_player_stat_by_slug!/2 returns nil if the player stats does not exist" do
      tournament = tournament_fixture()

      assert Tournaments.get_player_stat_by_slug!(tournament, "invalid-slug") == nil
    end

    test "get_player_stats_keys()/1 returns the keys of the player stats logs" do
      tournament = tournament_fixture()

      [fixed_stat, sum_stat, average_stat] = tournament.player_stats

      assert Tournaments.get_player_stats_keys(tournament) == [
               fixed_stat.slug,
               sum_stat.slug,
               average_stat.id
             ]
    end

    test "get_team_stats_keys()/1 returns the keys of the team stats logs" do
      tournament = tournament_fixture()

      [fixed_team_stat, fixed_source_stat, team_stat] = tournament.team_stats

      assert Tournaments.get_team_stats_keys(tournament) == [
               fixed_team_stat.slug,
               fixed_source_stat.slug,
               team_stat.id
             ]
    end
  end
end
