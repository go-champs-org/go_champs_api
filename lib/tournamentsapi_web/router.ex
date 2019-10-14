defmodule TournamentsApiWeb.Router do
  use TournamentsApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/swagger" do
    forward "/organization", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :tournamentsapi,
      swagger_file: "organization_swagger.json"
  end

  scope "/api", TournamentsApiWeb do
    pipe_through :api

    resources "/draws", DrawController
    resources "/eliminations", EliminationController
    resources "/games", GameController
    resources "/organizations", OrganizationController
    resources "/phases", PhaseController
    resources "/users", UserController
    resources "/teams", TeamController
    resources "/phases/:phase_id/stats", TournamentStatController
    resources "/tournaments", TournamentController
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Go Champs API Docs"
      }
    }
  end
end
