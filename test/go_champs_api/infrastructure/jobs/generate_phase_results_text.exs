defmodule GoChampsApi.Infrastructure.Jobs.GeneratePhaseResultsTest do
  use ExUnit.Case
  use GoChampsApi.DataCase
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Infrastructure.Jobs.GeneratePhaseResults

  alias GoChampsApi.Helpers.AggregatedTeamStatsByPhaseHelper
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Eliminations

  test "perform/1 updates phase depedencies" do
    team_stats =
      AggregatedTeamStatsByPhaseHelper.create_aggregated_team_stats_by_phase(%{
        "wins" => 7,
        "losses" => 3,
        "points" => 10
      })

    {:ok, phase} =
      team_stats.phase_id
      |> PhaseHelpers.set_elimination_stats([
        %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1},
        %{"title" => "Losses", "team_stat_source" => "losses"},
        %{"title" => "Points", "team_stat_source" => "points", "ranking_order" => 2}
      ])

    {:ok, elimination} =
      %{
        title: "some elimination",
        phase_id: phase.id,
        team_stats: [%{team_id: team_stats.team_id}]
      }
      |> Eliminations.create_elimination()

    assert GeneratePhaseResults.perform(%Oban.Job{args: %{"phase_id" => phase.id}}) ==
             {:ok, "Phase results has been generated for phase #{phase.id}"}

    [wins_stat, losses_stat, points_stat] = phase.elimination_stats

    updated_elimination = Eliminations.get_elimination!(elimination.id)

    [first_team_stats] = updated_elimination.team_stats

    assert first_team_stats.team_id == team_stats.team_id
    assert first_team_stats.stats[wins_stat.id] == 7
    assert first_team_stats.stats[losses_stat.id] == 3
    assert first_team_stats.stats[points_stat.id] == 10
  end
end
