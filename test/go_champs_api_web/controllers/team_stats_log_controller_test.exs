defmodule GoChampsApiWeb.TeamStatsLogControllerTest do
  alias GoChampsApi.Helpers.GameHelpers
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.TeamStatsLogs.TeamStatsLog
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers

  @create_attrs %{
    stats: %{
      some: "some"
    }
  }
  @update_attrs %{
    stats: %{
      some: "some updated"
    }
  }
  @invalid_attrs %{datetime: nil, stats: nil}

  def fixture(:team_stats_log) do
    {:ok, team_stats_log} =
      @create_attrs
      |> TeamHelpers.map_team_id_and_tournament_id()
      |> TeamHelpers.map_against_team_id()
      |> PhaseHelpers.map_phase_id_for_tournament()
      |> GameHelpers.map_game_id()
      |> TeamStatsLogs.create_team_stats_log()

    team_stats_log
  end

  def fixture(:team_stats_log_with_different_member) do
    {:ok, team_stats_log} =
      @create_attrs
      |> TeamHelpers.map_team_id_and_tournament_id_with_other_member()
      |> TeamHelpers.map_against_team_id()
      |> PhaseHelpers.map_phase_id_for_tournament()
      |> TeamStatsLogs.create_team_stats_log()

    team_stats_log
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all team_stats_log", %{conn: conn} do
      conn = get(conn, Routes.v1_team_stats_log_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "list all team_stats_logs matching where", %{conn: conn} do
      first_team_stats_log = fixture(:team_stats_log)

      {:ok, second_team_stats_logs} =
        @create_attrs
        |> Map.merge(%{
          tournament_id: first_team_stats_log.tournament_id,
          stats: %{
            some: "some other value"
          }
        })
        |> TeamHelpers.map_team_id_in_attrs()
        |> TeamHelpers.map_against_team_id()
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> GameHelpers.map_game_id()
        |> TeamStatsLogs.create_team_stats_log()

      where = %{
        "team_id" => second_team_stats_logs.team_id
      }

      conn = get(conn, Routes.v1_team_stats_log_path(conn, :index, where: where))
      [result_team_stats_log] = json_response(conn, 200)["data"]
      assert result_team_stats_log["id"] == second_team_stats_logs.id

      assert result_team_stats_log["stats"] == %{
               "some" => "some other value"
             }

      assert result_team_stats_log["game_id"] == second_team_stats_logs.game_id
      assert result_team_stats_log["team_id"] == second_team_stats_logs.team_id
    end
  end

  describe "create team_stats_log" do
    @tag :authenticated
    test "renders team_stats_log when data is valid", %{conn: conn} do
      create_attrs =
        @create_attrs
        |> TeamHelpers.map_team_id_and_tournament_id()
        |> TeamHelpers.map_against_team_id()
        |> PhaseHelpers.map_phase_id_for_tournament()

      conn =
        post(conn, Routes.v1_team_stats_log_path(conn, :create), team_stats_log: create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_team_stats_log_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "stats" => %{}
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs =
        @invalid_attrs
        |> TeamHelpers.map_team_id_and_tournament_id()

      conn =
        post(conn, Routes.v1_team_stats_log_path(conn, :create), team_stats_log: invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create team_stats_log with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      create_attrs =
        @create_attrs
        |> TeamHelpers.map_team_id_and_tournament_id_with_other_member()
        |> TeamHelpers.map_against_team_id()
        |> PhaseHelpers.map_phase_id_for_tournament()

      conn =
        post(conn, Routes.v1_team_stats_log_path(conn, :create), team_stats_log: create_attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update team_stats_log" do
    setup [:create_team_stats_log]

    @tag :authenticated
    test "renders team_stats_log when data is valid", %{
      conn: conn,
      team_stats_log: %TeamStatsLog{id: id} = team_stats_log
    } do
      conn =
        put(conn, Routes.v1_team_stats_log_path(conn, :update, team_stats_log),
          team_stats_log: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_team_stats_log_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "stats" => %{}
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, team_stats_log: team_stats_log} do
      conn =
        put(conn, Routes.v1_team_stats_log_path(conn, :update, team_stats_log),
          team_stats_log: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update team_stats_log with different member" do
    setup [:create_team_stats_log_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      team_stats_log: %TeamStatsLog{id: _id} = team_stats_log
    } do
      conn =
        put(conn, Routes.v1_team_stats_log_path(conn, :update, team_stats_log),
          team_stats_log: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete team_stats_log" do
    setup [:create_team_stats_log]

    @tag :authenticated
    test "deletes chosen team_stats_log", %{conn: conn, team_stats_log: team_stats_log} do
      conn = delete(conn, Routes.v1_team_stats_log_path(conn, :delete, team_stats_log))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_team_stats_log_path(conn, :show, team_stats_log))
      end
    end
  end

  describe "delete team_stats_log with different member" do
    setup [:create_team_stats_log_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      team_stats_log: team_stats_log
    } do
      conn =
        delete(
          conn,
          Routes.v1_team_stats_log_path(
            conn,
            :delete,
            team_stats_log
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_team_stats_log(_) do
    team_stats_log = fixture(:team_stats_log)
    %{team_stats_log: team_stats_log}
  end

  defp create_team_stats_log_with_different_member(_) do
    team_stats_log = fixture(:team_stats_log_with_different_member)
    {:ok, team_stats_log: team_stats_log}
  end
end
