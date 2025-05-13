defmodule GoChampsApiWeb.TeamStatsLogController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.TeamStatsLogs.TeamStatsLog

  action_fallback GoChampsApiWeb.FallbackController

  plug GoChampsApiWeb.Plugs.AuthorizedTeamStatsLog, :team_stats_log when action in [:create]
  plug GoChampsApiWeb.Plugs.AuthorizedTeamStatsLog, :id when action in [:delete, :update]

  defp map_to_keyword(map) do
    Enum.map(map, fn {key, value} -> {String.to_atom(key), value} end)
  end

  def index(conn, params) do
    team_stats_log =
      case params do
        %{"where" => where} ->
          where
          |> map_to_keyword()
          |> TeamStatsLogs.list_team_stats_log()

        _ ->
          TeamStatsLogs.list_team_stats_log()
      end

    render(conn, "index.json", team_stats_log: team_stats_log)
  end

  def create(conn, %{"team_stats_log" => team_stats_log_params}) do
    with {:ok, %TeamStatsLog{} = team_stats_log} <-
           TeamStatsLogs.create_team_stats_log(team_stats_log_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.v1_team_stats_log_path(conn, :show, team_stats_log))
      |> render("show.json", team_stats_log: team_stats_log)
    end
  end

  def show(conn, %{"id" => id}) do
    team_stats_log = TeamStatsLogs.get_team_stats_log!(id)
    render(conn, "show.json", team_stats_log: team_stats_log)
  end

  def update(conn, %{"id" => id, "team_stats_log" => team_stats_log_params}) do
    team_stats_log = TeamStatsLogs.get_team_stats_log!(id)

    with {:ok, %TeamStatsLog{} = team_stats_log} <-
           TeamStatsLogs.update_team_stats_log(team_stats_log, team_stats_log_params) do
      render(conn, "show.json", team_stats_log: team_stats_log)
    end
  end

  def delete(conn, %{"id" => id}) do
    team_stats_log = TeamStatsLogs.get_team_stats_log!(id)

    with {:ok, %TeamStatsLog{}} <- TeamStatsLogs.delete_team_stats_log(team_stats_log) do
      send_resp(conn, :no_content, "")
    end
  end
end
