defmodule GoChampsApiWeb.AggregatedPlayerStatsByTournamentControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Helpers.PlayerHelpers
  alias GoChampsApi.AggregatedPlayerStatsByTournaments
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Players
  alias GoChampsApi.Helpers.OrganizationHelpers
  alias GoChampsApi.PlayerStatsLogs

  @create_attrs %{
    stats: %{
      some: "some"
    }
  }
  @valid_tournament_attrs %{
    name: "some name",
    slug: "some-slug",
    player_stats: [
      %{
        title: "some stat"
      },
      %{
        title: "another stat"
      }
    ]
  }

  def fixture(:aggregated_player_stats_by_tournament) do
    attrs = PlayerHelpers.map_player_id_and_tournament_id(@create_attrs)

    {:ok, aggregated_player_stats_by_tournament} =
      AggregatedPlayerStatsByTournaments.create_aggregated_player_stats_by_tournament(attrs)

    aggregated_player_stats_by_tournament
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all aggregated_player_stats_by_tournament", %{conn: conn} do
      conn = get(conn, Routes.v1_aggregated_player_stats_by_tournament_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all tournaments matching where", %{conn: conn} do
      first_aggregated_player_stats = fixture(:aggregated_player_stats_by_tournament)

      tournament = Tournaments.get_tournament!(first_aggregated_player_stats.tournament_id)

      {:ok, other_tournament} =
        %{name: "some other tournament", slug: "some-other-tournament"}
        |> Map.merge(%{organization_id: tournament.organization_id})
        |> Tournaments.create_tournament()

      {:ok, second_aggregated_player_stats} =
        @create_attrs
        |> Map.merge(%{
          tournament_id: other_tournament.id,
          player_id: first_aggregated_player_stats.player_id
        })
        |> AggregatedPlayerStatsByTournaments.create_aggregated_player_stats_by_tournament()

      where = %{"tournament_id" => second_aggregated_player_stats.tournament_id}

      conn =
        get(
          conn,
          Routes.v1_aggregated_player_stats_by_tournament_path(conn, :index, where: where)
        )

      [aggregated_player_stats_result] = json_response(conn, 200)["data"]
      assert aggregated_player_stats_result["id"] == second_aggregated_player_stats.id
    end

    test "lists all tournaments matching where ordered", %{conn: conn} do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      [first_player_stat, second_player_stat] = tournament.player_stats

      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            first_player_stat.id => "6",
            second_player_stat.id => "2"
          }
        })

      {:ok, second_player} =
        %{name: "another player"}
        |> Map.merge(%{tournament_id: tournament.id})
        |> Players.create_player()

      second_valid_attrs = %{
        stats: %{first_player_stat.id => "4", second_player_stat.id => "3"},
        player_id: second_player.id,
        tournament_id: first_valid_attrs.tournament_id
      }

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([second_valid_attrs, first_valid_attrs])

      AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      where = %{"tournament_id" => tournament.id}

      conn =
        get(
          conn,
          Routes.v1_aggregated_player_stats_by_tournament_path(conn, :index, where: where)
        )

      [first_aggregated_player_stats_result, second_aggregated_player_stats_result] =
        json_response(conn, 200)["data"]

      assert Map.fetch(first_aggregated_player_stats_result["stats"], first_player_stat.id) ==
               {:ok, 6}

      assert Map.fetch(second_aggregated_player_stats_result["stats"], first_player_stat.id) ==
               {:ok, 4}
    end

    test "lists all tournaments matching where ordered by given sort id", %{conn: conn} do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      [first_player_stat, second_player_stat] = tournament.player_stats

      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            first_player_stat.id => "6",
            second_player_stat.id => "2"
          }
        })

      {:ok, second_player} =
        %{name: "another player"}
        |> Map.merge(%{tournament_id: tournament.id})
        |> Players.create_player()

      second_valid_attrs = %{
        stats: %{first_player_stat.id => "4", second_player_stat.id => "3"},
        player_id: second_player.id,
        tournament_id: first_valid_attrs.tournament_id
      }

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([second_valid_attrs, first_valid_attrs])

      AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      where = %{"tournament_id" => tournament.id}

      sort = second_player_stat.id

      conn =
        get(
          conn,
          Routes.v1_aggregated_player_stats_by_tournament_path(conn, :index,
            where: where,
            sort: sort
          )
        )

      [first_aggregated_player_stats_result, second_aggregated_player_stats_result] =
        json_response(conn, 200)["data"]

      assert Map.fetch(first_aggregated_player_stats_result["stats"], second_player_stat.id) ==
               {:ok, 3}

      assert Map.fetch(second_aggregated_player_stats_result["stats"], second_player_stat.id) ==
               {:ok, 2}
    end
  end
end
