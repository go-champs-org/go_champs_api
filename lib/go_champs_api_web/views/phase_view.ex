defmodule GoChampsApiWeb.PhaseView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.DrawView
  alias GoChampsApiWeb.EliminationView
  alias GoChampsApiWeb.PhaseView

  def render("index.json", %{phases: phases}) do
    %{data: render_many(phases, PhaseView, "phase.json")}
  end

  def render("batch_list.json", %{phases: phases}) do
    phases_view =
      phases
      |> Map.keys()
      |> Enum.reduce(%{}, fn phase_id, acc_phases ->
        Map.put(
          acc_phases,
          phase_id,
          render_one(Map.get(phases, phase_id), PhaseView, "phase.json")
        )
      end)

    %{data: phases_view}
  end

  def render("show.json", %{phase: phase}) do
    %{
      data: %{
        id: phase.id,
        order: phase.order,
        draws: render_many(phase.draws, DrawView, "draw.json"),
        eliminations: render_many(phase.eliminations, EliminationView, "elimination.json"),
        elimination_stats:
          render_many(phase.elimination_stats, PhaseView, "elimination_stats.json"),
        is_in_progress: phase.is_in_progress,
        title: phase.title,
        type: phase.type
      }
    }
  end

  def render("phase.json", %{phase: phase}) do
    %{
      id: phase.id,
      order: phase.order,
      elimination_stats:
        render_many(phase.elimination_stats, PhaseView, "elimination_stats.json"),
      is_in_progress: phase.is_in_progress,
      title: phase.title,
      type: phase.type
    }
  end

  def render("elimination_stats.json", %{phase: elimination_stats}) do
    %{
      id: elimination_stats.id,
      title: elimination_stats.title
    }
  end
end
