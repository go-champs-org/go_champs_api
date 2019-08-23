defmodule TournamentsApiWeb.Router do
  use TournamentsApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", TournamentsApiWeb do
    pipe_through :api

    resources "/games", GameController
    resources "/organizations", OrganizationController
    resources "/teams", TeamController
    resources "/users", UserController
    resources "/phases/:tournament_phase_id/stats", TournamentStatController
    resources "/phases/:tournament_phase_id/groups", TournamentGroupController
    resources "/tournaments", TournamentController
    resources "/tournaments/:tournament_id/games", TournamentGameController
    resources "/tournaments/:tournament_id/phases", TournamentPhaseController
    resources "/tournaments/:tournament_id/teams", TournamentTeamController
  end
end
