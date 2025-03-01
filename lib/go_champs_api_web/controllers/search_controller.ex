defmodule GoChampsApiWeb.SearchController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.Tournaments

  action_fallback GoChampsApiWeb.FallbackController

  def index(conn, params) do
    tournaments =
      case params do
        %{"term" => term} ->
          term
          |> Tournaments.search_tournaments()

        _ ->
          Tournaments.list_tournaments(visibility: "public")
      end

    render(conn, "index.json", tournaments: tournaments)
  end
end
