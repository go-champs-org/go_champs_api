defmodule GoChampsApiWeb.ScoreboardSettingController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.ScoreboardSettings
  alias GoChampsApi.ScoreboardSettings.ScoreboardSetting

  action_fallback GoChampsApiWeb.FallbackController

  plug GoChampsApiWeb.Plugs.AuthorizedScoreboardSetting, :id when action in [:delete, :update]

  plug GoChampsApiWeb.Plugs.AuthorizedScoreboardSetting,
       :scoreboard_setting when action in [:create]

  def index(conn, _params) do
    scoreboard_settings = ScoreboardSettings.list_scoreboard_settings()
    render(conn, "index.json", scoreboard_settings: scoreboard_settings)
  end

  def create(conn, %{"scoreboard_setting" => scoreboard_setting_params}) do
    with {:ok, %ScoreboardSetting{} = scoreboard_setting} <-
           ScoreboardSettings.create_scoreboard_setting(scoreboard_setting_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.v1_scoreboard_setting_path(conn, :show, scoreboard_setting)
      )
      |> render("show.json", scoreboard_setting: scoreboard_setting)
    end
  end

  def show(conn, %{"id" => id}) do
    scoreboard_setting = ScoreboardSettings.get_scoreboard_setting!(id)
    render(conn, "show.json", scoreboard_setting: scoreboard_setting)
  end

  def update(conn, %{"id" => id, "scoreboard_setting" => scoreboard_setting_params}) do
    scoreboard_setting = ScoreboardSettings.get_scoreboard_setting!(id)

    with {:ok, %ScoreboardSetting{} = scoreboard_setting} <-
           ScoreboardSettings.update_scoreboard_setting(
             scoreboard_setting,
             scoreboard_setting_params
           ) do
      render(conn, "show.json", scoreboard_setting: scoreboard_setting)
    end
  end

  def delete(conn, %{"id" => id}) do
    scoreboard_setting = ScoreboardSettings.get_scoreboard_setting!(id)

    with {:ok, %ScoreboardSetting{}} <-
           ScoreboardSettings.delete_scoreboard_setting(scoreboard_setting) do
      send_resp(conn, :no_content, "")
    end
  end
end
