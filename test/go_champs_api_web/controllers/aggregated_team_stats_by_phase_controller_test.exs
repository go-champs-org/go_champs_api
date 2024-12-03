defmodule GoChampsApiWeb.AggregatedTeamStatsByPhaseControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers

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

  def fixture(:aggregated_team_stats_by_phase) do
    attrs =
      @valid_attrs
      |> TeamHelpers.map_team_id_and_tournament_id()
      |> PhaseHelpers.map_phase_id_for_tournament()

    {:ok, aggregated_team_stats_by_phase} =
      AggregatedTeamStatsByPhases.create_aggregated_team_stats_by_phase(attrs)

    aggregated_team_stats_by_phase
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all aggregated_team_stats_by_phase", %{conn: conn} do
      conn = get(conn, Routes.v1_aggregated_team_stats_by_phase_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end
end
