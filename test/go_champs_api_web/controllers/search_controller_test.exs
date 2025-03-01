defmodule GoChampsApiWeb.SearchControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Organizations
  alias GoChampsApi.Tournaments

  @create_attrs %{name: "some name", slug: "some-slug"}

  @organization_attrs %{name: "some organization", slug: "some-org-slug"}

  def fixture(:tournament, organization_params \\ @organization_attrs) do
    {:ok, organization} = Organizations.create_organization(organization_params)

    attrs = Map.merge(@create_attrs, %{organization_id: organization.id})
    {:ok, tournament} = Tournaments.create_tournament(attrs)
    tournament
  end

  describe "index" do
    test "lists all tournaments", %{conn: conn} do
      conn = get(conn, Routes.v1_search_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "list all tournaments that are public", %{conn: conn} do
      tournament = fixture(:tournament)

      {:ok, _private_tournamet} =
        %{
          organization_id: tournament.organization_id,
          visibility: "private",
          name: "private tournament",
          slug: "private-tournament"
        }
        |> Tournaments.create_tournament()

      conn = get(conn, Routes.v1_search_path(conn, :index))
      [tournament_result] = json_response(conn, 200)["data"]
      assert tournament_result["id"] == tournament.id
    end

    test "lists all tournaments matching where", %{conn: conn} do
      fixture(:tournament)

      second_tournament =
        fixture(:tournament, %{name: "another organization", slug: "another-org-slug"})

      term = "another"

      conn = get(conn, Routes.v1_search_path(conn, :index, term: term))
      [tournament_result] = json_response(conn, 200)["data"]
      assert tournament_result["id"] == second_tournament.id
    end
  end
end
