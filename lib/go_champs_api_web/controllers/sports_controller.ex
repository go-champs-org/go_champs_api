defmodule GoChampsApiWeb.SportsController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.Sports

  action_fallback GoChampsApiWeb.FallbackController

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, params) do
    sports = Sports.list_sports()

    render(conn, "index.json", sports: sports)
  end

  @spec show(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def show(conn, %{"id" => slug}) do
    sport = Sports.get_sport(slug)

    render(conn, "show.json", sport: sport)
  end
end
