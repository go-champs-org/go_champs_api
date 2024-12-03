defmodule GoChampsApiWeb.RecentlyViewControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.RecentlyViews

  @create_attrs %{}
  @invalid_attrs %{}

  def fixture(:recently_view) do
    {:ok, recently_view} =
      @create_attrs
      |> TournamentHelpers.map_tournament_id()
      |> RecentlyViews.create_recently_view()

    recently_view
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    setup [:create_recently_view]

    test "lists all recently_view", %{conn: conn, recently_view: recently_view} do
      conn = get(conn, Routes.v1_recently_view_path(conn, :index))

      [recently_view_result] = json_response(conn, 200)["data"]
      assert recently_view_result["tournament"]["id"] == recently_view.tournament_id
      assert recently_view_result["views"] == 1
    end
  end

  describe "create recently_view" do
    test "renders recently_view when data is valid", %{conn: conn} do
      create_attrs = TournamentHelpers.map_tournament_id(@create_attrs)
      conn = post(conn, Routes.v1_recently_view_path(conn, :create), recently_view: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_recently_view_path(conn, :show, id))

      assert %{
               "id" => ^id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.v1_recently_view_path(conn, :create), recently_view: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  defp create_recently_view(_) do
    recently_view = fixture(:recently_view)
    %{recently_view: recently_view}
  end
end
