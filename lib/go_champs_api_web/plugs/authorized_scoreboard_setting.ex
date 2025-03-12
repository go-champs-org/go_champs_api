defmodule GoChampsApiWeb.Plugs.AuthorizedScoreboardSetting do
  import Phoenix.Controller
  import Plug.Conn

  alias GoChampsApi.Tournaments
  alias GoChampsApi.ScoreboardSettings

  def init(default), do: default

  def call(conn, :scoreboard_setting) do
    {:ok, scoreboard_setting} = Map.fetch(conn.params, "scoreboard_setting")
    {:ok, tournament_id} = Map.fetch(scoreboard_setting, "tournament_id")

    organization = Tournaments.get_tournament_organization!(tournament_id)
    current_user = Guardian.Plug.current_resource(conn)

    if Enum.any?(organization.members, fn member -> member.username == current_user.username end) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> text("Forbidden")
      |> halt
    end
  end

  def call(conn, :id) do
    {:ok, scoreboard_setting_id} = Map.fetch(conn.params, "id")

    organization = ScoreboardSettings.get_scoreboard_setting_organization!(scoreboard_setting_id)
    current_user = Guardian.Plug.current_resource(conn)

    if Enum.any?(organization.members, fn member -> member.username == current_user.username end) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> text("Forbidden")
      |> halt
    end
  end
end
