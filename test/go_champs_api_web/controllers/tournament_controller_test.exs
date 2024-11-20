defmodule GoChampsApiWeb.TournamentControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Organizations
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Tournaments.Tournament

  @create_attrs %{
    name: "some name",
    slug: "some-slug",
    facebook: "facebook",
    instagram: "instagram",
    site_url: "site url",
    twitter: "twitter",
    player_stats: [
      %{
        title: "fixed stat"
      },
      %{
        title: "sum stat"
      },
      %{
        title: "average stat"
      }
    ],
    team_stats: [
      %{
        title: "team fixed stat",
        is_default_order: true
      },
      %{
        title: "team source stat",
        source: "player-stat-id"
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

  @organization_attrs %{
    name: "some organization",
    slug: "some-org-slug",
    members: [
      %{
        username: "someuser"
      }
    ]
  }

  def fixture(:tournament, organization_params \\ @organization_attrs) do
    {:ok, organization} = Organizations.create_organization(organization_params)

    attrs = Map.merge(@create_attrs, %{organization_id: organization.id})
    {:ok, tournament} = Tournaments.create_tournament(attrs)
    tournament
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all tournaments", %{conn: conn} do
      conn = get(conn, Routes.v1_tournament_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all tournaments matching where", %{conn: conn} do
      fixture(:tournament)

      second_tournament =
        fixture(:tournament, %{name: "another organization", slug: "another-org-slug"})

      where = %{"organization_id" => second_tournament.organization_id}

      conn = get(conn, Routes.v1_tournament_path(conn, :index, where: where))
      [tournament_result] = json_response(conn, 200)["data"]
      assert tournament_result["id"] == second_tournament.id
    end
  end

  describe "create tournament" do
    @tag :authenticated
    test "renders tournament when data is valid", %{conn: conn} do
      {:ok, organization} = Organizations.create_organization(@organization_attrs)

      attrs = Map.merge(@create_attrs, %{organization_id: organization.id})

      conn = post(conn, Routes.v1_tournament_path(conn, :create), tournament: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_tournament_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => result_name,
               "slug" => result_slug,
               "facebook" => result_facebook,
               "instagram" => result_instagram,
               "site_url" => result_site,
               "twitter" => result_twitter,
               "player_stats" => result_player_stats,
               "team_stats" => result_team_stats,
               "has_aggregated_player_stats" => result_has_aggregated_player_stats,
               "sport_slug" => result_sport_slug,
               "sport_name" => result_sport_name
             } = json_response(conn, 200)["data"]

      assert result_name == "some name"
      assert result_slug == "some-slug"
      assert result_facebook == "facebook"
      assert result_instagram == "instagram"
      assert result_site == "site url"
      assert result_twitter == "twitter"
      assert result_has_aggregated_player_stats == false
      assert result_sport_slug == "basketball_5x5"
      assert result_sport_name == "Basketball 5x5"

      [fixed_stat, sum_stat, average_stat] = result_player_stats

      assert fixed_stat["title"] == "fixed stat"
      assert sum_stat["title"] == "sum stat"
      assert average_stat["title"] == "average stat"

      [fixed_team_stat, source_team_stat] = result_team_stats

      assert fixed_team_stat["title"] == "team fixed stat"
      assert fixed_team_stat["is_default_order"] == true
      assert source_team_stat["title"] == "team source stat"
      assert source_team_stat["source"] == "player-stat-id"
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      {:ok, organization} = Organizations.create_organization(@organization_attrs)

      attrs = Map.merge(@invalid_attrs, %{organization_id: organization.id})

      conn = post(conn, Routes.v1_tournament_path(conn, :create), tournament: attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create tournament with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      {:ok, organization} =
        Organizations.create_organization(%{
          members: [
            %{
              username: "someotheruser"
            }
          ],
          name: "some organization",
          slug: "some-org-slug"
        })

      attrs = Map.merge(@create_attrs, %{organization_id: organization.id})

      conn = post(conn, Routes.v1_tournament_path(conn, :create), tournament: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update tournament" do
    setup [:create_tournament]

    @tag :authenticated
    test "renders tournament when data is valid", %{
      conn: conn,
      tournament: %Tournament{id: id} = tournament
    } do
      conn =
        put(conn, Routes.v1_tournament_path(conn, :update, tournament), tournament: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_tournament_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "name" => result_name,
               "slug" => result_slug,
               "facebook" => result_facebook,
               "instagram" => result_instagram,
               "site_url" => result_site,
               "twitter" => result_twitter
             } = json_response(conn, 200)["data"]

      assert result_name == "some updated name"
      assert result_slug == "some-updated-slug"
      assert result_facebook == "facebook updated"
      assert result_instagram == "instagram updated"
      assert result_site == "site url updated"
      assert result_twitter == "twitter updated"
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, tournament: tournament} do
      conn =
        put(conn, Routes.v1_tournament_path(conn, :update, tournament), tournament: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update tournament with different member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn
    } do
      tournament =
        fixture(:tournament, %{
          name: "another organization",
          slug: "another-org-slug",
          members: [
            %{
              username: "someotheruser"
            }
          ]
        })

      conn =
        put(conn, Routes.v1_tournament_path(conn, :update, tournament), tournament: @update_attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete tournament" do
    setup [:create_tournament]

    @tag :authenticated
    test "deletes chosen tournament", %{conn: conn, tournament: tournament} do
      conn = delete(conn, Routes.v1_tournament_path(conn, :delete, tournament))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_tournament_path(conn, :show, tournament))
      end
    end
  end

  describe "delete tournament with different member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn
    } do
      tournament =
        fixture(:tournament, %{
          name: "another organization",
          slug: "another-org-slug",
          members: [
            %{
              username: "someotheruser"
            }
          ]
        })

      conn = delete(conn, Routes.v1_tournament_path(conn, :delete, tournament))

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_tournament(_) do
    tournament = fixture(:tournament)
    {:ok, tournament: tournament}
  end
end
