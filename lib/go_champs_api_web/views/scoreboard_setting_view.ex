defmodule GoChampsApiWeb.ScoreboardSettingView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.ScoreboardSettingView

  def render("index.json", %{scoreboard_settings: scoreboard_settings}) do
    %{data: render_many(scoreboard_settings, ScoreboardSettingView, "scoreboard_setting.json")}
  end

  def render("show.json", %{scoreboard_setting: scoreboard_setting}) do
    %{data: render_one(scoreboard_setting, ScoreboardSettingView, "scoreboard_setting.json")}
  end

  def render("scoreboard_setting.json", %{scoreboard_setting: scoreboard_setting}) do
    %{
      id: scoreboard_setting.id,
      view: scoreboard_setting.view,
      initial_period_time: scoreboard_setting.initial_period_time
    }
  end
end
