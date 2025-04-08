defmodule GoChampsApiWeb.AggregatedTeamHeadToHeadStatsByPhaseControllerTest do
  use GoChampsApiWeb.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all aggregated_team_head_to_head_stats_by_phase", %{conn: conn} do
      conn = get(conn, Routes.v1_aggregated_team_head_to_head_stats_by_phase_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end
end
