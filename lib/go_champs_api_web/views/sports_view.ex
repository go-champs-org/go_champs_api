defmodule GoChampsApiWeb.SportsView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.SportsView

  def render("index.json", %{sports: sports}) do
    %{data: render_many(sports, SportsView, "sport.json", as: :sport)}
  end

  def render("show.json", %{sport: sport}) do
    %{
      data: render_one(sport, SportsView, "sport.json", as: :sport)
    }
  end

  def render("sport.json", %{sport: sport}) do
    %{
      slug: sport.slug,
      name: sport.name,
      player_statistics:
        render_many(sport.player_statistics, SportsView, "player_statistic.json",
          as: :player_statistic
        ),
      coach_types:
        render_many(sport.coach_types, SportsView, "coachs_type.json", as: :coachs_type)
    }
  end

  def render("player_statistic.json", %{player_statistic: player_statistic}) do
    %{
      slug: player_statistic.slug,
      name: player_statistic.name,
      value_type: player_statistic.value_type,
      level: player_statistic.level,
      scope: player_statistic.scope
    }
  end

  def render("coachs_type.json", %{coachs_type: coachs_type}) do
    %{
      type: coachs_type.type
    }
  end
end
