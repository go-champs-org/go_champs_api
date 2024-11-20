defmodule GoChampsApiWeb.SportsController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.Sports

  action_fallback GoChampsApiWeb.FallbackController

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, params) do
    sports = Sports.list_sports()

    render(conn, "index.json", sports: sports)
  end
end
