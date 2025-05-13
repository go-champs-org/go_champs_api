defmodule GoChampsApiWeb.TeamControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Teams
  alias GoChampsApi.Teams.Team

  @create_attrs %{
    name: "some name",
    logo_url: "https://www.example.com/logo.png",
    tri_code: "TST",
    coaches: [
      %{
        name: "Some Coach",
        type: "head_coach"
      }
    ]
  }
  @update_attrs %{
    name: "some updated name",
    coaches: [
      %{
        name: "Replaced Coach",
        type: "head_coach"
      }
    ]
  }
  @invalid_attrs %{name: nil}

  def fixture(:team) do
    {:ok, team} =
      @create_attrs
      |> TournamentHelpers.map_tournament_id()
      |> Teams.create_team()

    team
  end

  def fixture(:team_with_different_member) do
    attrs = TournamentHelpers.map_tournament_id_with_other_member(@create_attrs)
    {:ok, team} = Teams.create_team(attrs)
    team
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create team" do
    @tag :authenticated
    test "renders team when data is valid", %{conn: conn} do
      create_attrs = TournamentHelpers.map_tournament_id(@create_attrs)
      conn = post(conn, Routes.v1_team_path(conn, :create), team: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_team_path(conn, :show, id))

      response = json_response(conn, 200)["data"]
      [coach] = response["coaches"]

      assert response["id"] == id
      assert response["name"] == "some name"
      assert response["logo_url"] == "https://www.example.com/logo.png"
      assert response["tri_code"] == "TST"
      assert coach["name"] == "Some Coach"
      assert coach["type"] == "head_coach"
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      create_attrs = TournamentHelpers.map_tournament_id(@invalid_attrs)
      conn = post(conn, Routes.v1_team_path(conn, :create), team: create_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create team with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = TournamentHelpers.map_tournament_id_with_other_member(@create_attrs)

      conn = post(conn, Routes.v1_team_path(conn, :create), team: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update team" do
    setup [:create_team]

    @tag :authenticated
    test "renders team when data is valid", %{conn: conn, team: %Team{id: id} = team} do
      conn = put(conn, Routes.v1_team_path(conn, :update, team), team: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_team_path(conn, :show, id))

      response = json_response(conn, 200)["data"]
      [coach] = response["coaches"]
      assert response["id"] == id
      assert response["name"] == "some updated name"
      assert response["logo_url"] == "https://www.example.com/logo.png"
      assert response["tri_code"] == "TST"
      assert coach["name"] == "Replaced Coach"
      assert coach["type"] == "head_coach"
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, team: team} do
      conn = put(conn, Routes.v1_team_path(conn, :update, team), team: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update team with different member" do
    setup [:create_team_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, team: team} do
      conn =
        put(
          conn,
          Routes.v1_team_path(
            conn,
            :update,
            team
          ),
          team: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete team" do
    setup [:create_team]

    @tag :authenticated
    test "deletes chosen team", %{conn: conn, team: team} do
      conn = delete(conn, Routes.v1_team_path(conn, :delete, team))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_team_path(conn, :show, team))
      end
    end
  end

  describe "delete team with different member" do
    setup [:create_team_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, team: team} do
      conn =
        delete(
          conn,
          Routes.v1_team_path(
            conn,
            :delete,
            team
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_team(_) do
    team = fixture(:team)
    {:ok, team: team}
  end

  defp create_team_with_different_member(_) do
    team = fixture(:team_with_different_member)
    {:ok, team: team}
  end
end
