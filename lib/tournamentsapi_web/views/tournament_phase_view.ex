defmodule TournamentsApiWeb.TournamentPhaseView do
  use TournamentsApiWeb, :view
  alias TournamentsApiWeb.PhaseRoundView
  alias TournamentsApiWeb.PhaseStandingsView
  alias TournamentsApiWeb.TournamentPhaseView
  alias TournamentsApiWeb.TournamentStatView

  def render("index.json", %{tournament_phases: tournament_phases}) do
    %{data: render_many(tournament_phases, TournamentPhaseView, "tournament_phase.json")}
  end

  def render("show.json", %{tournament_phase: tournament_phase}) do
    %{
      data: %{
        id: tournament_phase.id,
        order: tournament_phase.order,
        rounds: render_many(tournament_phase.rounds, PhaseRoundView, "phase_round.json"),
        standings:
          render_many(tournament_phase.standings, PhaseStandingsView, "phase_standings.json"),
        stats: render_many(tournament_phase.stats, TournamentStatView, "tournament_stat.json"),
        title: tournament_phase.title,
        type: tournament_phase.type
      }
    }
  end

  def render("tournament_phase.json", %{tournament_phase: tournament_phase}) do
    %{
      id: tournament_phase.id,
      order: tournament_phase.order,
      title: tournament_phase.title,
      type: tournament_phase.type
    }
  end
end
