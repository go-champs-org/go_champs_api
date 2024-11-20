defmodule GoChampsApiWeb.SportsView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.SportsView

  def render("index.json", %{sports: sports}) do
    %{data: render_many(sports, SportsView, "sport.json", as: :sport)}
  end

  def render("show.json", %{sport: sport}) do
    %{data: render_one(sport, SportsView, "sport.json")}
  end

  def render("sport.json", %{sport: sport}) do
    %{slug: sport.slug, name: sport.name}
  end
end
