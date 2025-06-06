defmodule GoChampsApi.PhasesTest do
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.TeamHelpers
  use GoChampsApi.DataCase

  alias GoChampsApi.Helpers.AggregatedTeamStatsByPhaseHelper
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.AggregatedTeamStatsByPhases
  alias GoChampsApi.AggregatedTeamHeadToHeadStatsByPhases
  alias GoChampsApi.Draws
  alias GoChampsApi.Eliminations
  alias GoChampsApi.Organizations
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Phases

  describe "phases" do
    alias GoChampsApi.Phases.Phase

    @valid_attrs %{
      is_in_progress: true,
      title: "some title",
      type: "elimination",
      elimination_stats: [
        %{"title" => "stat title", "team_stat_source" => "points", "ranking_order" => 1}
      ],
      ranking_tie_breakers: [
        %{"type" => "head_to_head", "order" => 1}
      ]
    }
    @update_attrs %{
      is_in_progress: false,
      title: "some updated title",
      type: "elimination",
      elimination_stats: [%{"title" => "updated stat title"}]
    }
    @invalid_attrs %{title: nil, type: nil}

    def phase_fixture(attrs \\ %{}) do
      {:ok, phase} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TournamentHelpers.map_tournament_id()
        |> Phases.create_phase()

      phase
    end

    test "get_phase!/1 returns the phase with given id" do
      phase = phase_fixture()

      assert Phases.get_phase!(phase.id).id == phase.id
    end

    test "get_phase_organization!/1 returns the organization with a give phase id" do
      phase = phase_fixture()

      organization = Phases.get_phase_organization!(phase.id)

      tournament = Tournaments.get_tournament!(phase.tournament_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "create_phase/1 with valid data creates a phase" do
      attrs = TournamentHelpers.map_tournament_id(@valid_attrs)

      assert {:ok, %Phase{} = phase} = Phases.create_phase(attrs)

      assert phase.title == "some title"
      assert phase.type == "elimination"
      assert phase.order == 1
      assert phase.is_in_progress == true
      [elimination_stat] = phase.elimination_stats
      assert elimination_stat.title == "stat title"
      assert elimination_stat.team_stat_source == "points"
      assert elimination_stat.ranking_order == 1
      [ranking_tie_breaker] = phase.ranking_tie_breakers
      assert ranking_tie_breaker.type == "head_to_head"
      assert ranking_tie_breaker.order == 1
    end

    test "create_phase/1 for elimination type" do
      attrs = TournamentHelpers.map_tournament_id(@valid_attrs)
      attrs = Map.put(attrs, :type, "elimination")

      assert {:ok, %Phase{} = phase} = Phases.create_phase(attrs)

      assert phase.type == "elimination"
    end

    test "create_phase/1 for draw type" do
      attrs = TournamentHelpers.map_tournament_id(@valid_attrs)
      attrs = Map.put(attrs, :type, "draw")

      assert {:ok, %Phase{} = phase} = Phases.create_phase(attrs)

      assert phase.type == "draw"
    end

    test "create_phase/1 with invalid type" do
      attrs = TournamentHelpers.map_tournament_id(@valid_attrs)
      attrs = Map.put(attrs, :type, "invalid")

      assert {:error, %Ecto.Changeset{}} = Phases.create_phase(attrs)
    end

    test "create_phase/1 with invalid ranking tie breaker type" do
      attrs = TournamentHelpers.map_tournament_id(@valid_attrs)
      attrs = Map.put(attrs, :ranking_tie_breakers, [%{"type" => "invalid", "order" => 1}])

      assert {:error, %Ecto.Changeset{}} = Phases.create_phase(attrs)
    end

    test "create_phase/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Phases.create_phase(@invalid_attrs)
    end

    test "create_phase/1 select order for second item" do
      attrs = TournamentHelpers.map_tournament_id(@valid_attrs)

      assert {:ok, %Phase{} = first_phase} = Phases.create_phase(attrs)

      assert {:ok, %Phase{} = second_phase} = Phases.create_phase(attrs)

      assert first_phase.order == 1
      assert second_phase.order == 2
    end

    test "create_phase/1 set order as 1 for new phase" do
      first_attrs = TournamentHelpers.map_tournament_id(@valid_attrs)

      assert {:ok, %Phase{} = first_phase} = Phases.create_phase(first_attrs)

      [organization] = Organizations.list_organizations()

      {:ok, second_tournament} =
        Tournaments.create_tournament(%{
          name: "some other tournament name",
          slug: "some-other-slug",
          organization_id: organization.id
        })

      second_attrs = Map.merge(@valid_attrs, %{tournament_id: second_tournament.id})

      assert {:ok, %Phase{} = second_phase} = Phases.create_phase(second_attrs)

      assert first_phase.order == 1
      assert second_phase.order == 1
    end

    test "update_phase/2 with valid data updates the phase" do
      phase = phase_fixture()

      assert {:ok, %Phase{} = phase} = Phases.update_phase(phase, @update_attrs)

      assert phase.title == "some updated title"
      assert phase.type == "elimination"
      assert phase.is_in_progress == false
      [elimination_stat] = phase.elimination_stats
      assert elimination_stat.title == "updated stat title"
    end

    test "update_phase/2 with invalid data returns error changeset" do
      phase = phase_fixture()

      assert {:error, %Ecto.Changeset{}} = Phases.update_phase(phase, @invalid_attrs)

      result_phase = Phases.get_phase!(phase.id)

      assert phase.id == result_phase.id
    end

    test "update_phases/1 with valid data updates the phase" do
      attrs = TournamentHelpers.map_tournament_id(@valid_attrs)

      {:ok, %Phase{} = first_phase} = Phases.create_phase(attrs)
      {:ok, %Phase{} = second_phase} = Phases.create_phase(attrs)

      first_updated_phase = %{"id" => first_phase.id, "title" => "some first updated title"}
      second_updated_phase = %{"id" => second_phase.id, "title" => "some second updated title"}

      {:ok, batch_results} = Phases.update_phases([first_updated_phase, second_updated_phase])

      assert batch_results[first_phase.id].id == first_phase.id
      assert batch_results[first_phase.id].title == "some first updated title"
      assert batch_results[second_phase.id].id == second_phase.id
      assert batch_results[second_phase.id].title == "some second updated title"
    end

    test "get_phases_tournament_id/1 with valid data return pertaning tournament" do
      attrs = TournamentHelpers.map_tournament_id(@valid_attrs)

      {:ok, %Phase{} = first_phase} = Phases.create_phase(attrs)
      {:ok, %Phase{} = second_phase} = Phases.create_phase(attrs)

      first_updated_phase = %{"id" => first_phase.id, "title" => "some first updated title"}
      second_updated_phase = %{"id" => second_phase.id, "title" => "some second updated title"}

      {:ok, tournament_id} =
        Phases.get_phases_tournament_id([first_updated_phase, second_updated_phase])

      assert tournament_id == attrs.tournament_id
    end

    test "get_phases_tournament_id/1 with multiple tournament associated returns error" do
      first_attrs = TournamentHelpers.map_tournament_id(@valid_attrs)
      tournament = Tournaments.get_tournament!(first_attrs.tournament_id)

      {:ok, second_tournament} =
        Tournaments.create_tournament(%{
          name: "some other tournament name",
          slug: "some-other-slug",
          organization_id: tournament.organization.id
        })

      second_attrs = Map.merge(@valid_attrs, %{tournament_id: second_tournament.id})

      {:ok, %Phase{} = first_phase} = Phases.create_phase(first_attrs)
      {:ok, %Phase{} = second_phase} = Phases.create_phase(second_attrs)

      first_updated_phase = %{"id" => first_phase.id, "title" => "some first updated title"}
      second_updated_phase = %{"id" => second_phase.id, "title" => "some second updated title"}

      assert {:error, "Can only update phase from same tournament"} =
               Phases.get_phases_tournament_id([first_updated_phase, second_updated_phase])
    end

    test "delete_phase/1 deletes the phase" do
      phase = phase_fixture()
      assert {:ok, %Phase{}} = Phases.delete_phase(phase)

      assert_raise Ecto.NoResultsError, fn ->
        Phases.get_phase!(phase.id)
      end
    end

    test "change_phase/1 returns a phase changeset" do
      phase = phase_fixture()
      assert %Ecto.Changeset{} = Phases.change_phase(phase)
    end
  end

  describe "generate_phase_results/1" do
    test "for elimination, returns :ok and update eliminations team stats and sort them" do
      second_team_stats_first_elimination =
        AggregatedTeamStatsByPhaseHelper.create_aggregated_team_stats_by_phase(%{
          "wins" => 7,
          "losses" => 3,
          "points" => 10
        })

      {:ok, first_team_stats_first_elimination} =
        %{
          phase_id: second_team_stats_first_elimination.phase_id,
          tournament_id: second_team_stats_first_elimination.tournament_id,
          stats: %{
            "wins" => 7,
            "losses" => 4,
            "points" => 15
          }
        }
        |> TeamHelpers.map_team_id_in_attrs()
        |> AggregatedTeamStatsByPhases.create_aggregated_team_stats_by_phase()

      {:ok, first_team_stats_second_elimination} =
        %{
          phase_id: second_team_stats_first_elimination.phase_id,
          tournament_id: second_team_stats_first_elimination.tournament_id,
          stats: %{
            "wins" => 10,
            "losses" => 0,
            "points" => 50
          }
        }
        |> TeamHelpers.map_team_id_in_attrs()
        |> AggregatedTeamStatsByPhases.create_aggregated_team_stats_by_phase()

      {:ok, second_team_stats_second_elimination} =
        %{
          phase_id: second_team_stats_first_elimination.phase_id,
          tournament_id: second_team_stats_first_elimination.tournament_id,
          stats: %{
            "wins" => 7,
            "losses" => 3,
            "points" => 40
          }
        }
        |> TeamHelpers.map_team_id_in_attrs()
        |> AggregatedTeamStatsByPhases.create_aggregated_team_stats_by_phase()

      {:ok, phase} =
        second_team_stats_first_elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1},
          %{"title" => "Losses", "team_stat_source" => "losses"},
          %{"title" => "Points", "team_stat_source" => "points", "ranking_order" => 2}
        ])

      {:ok, first_elimination} =
        @valid_attrs
        |> Map.put(:phase_id, phase.id)
        |> Map.put(:team_stats, [
          %{team_id: second_team_stats_first_elimination.team_id},
          %{team_id: first_team_stats_first_elimination.team_id}
        ])
        |> Eliminations.create_elimination()

      {:ok, second_elimination} =
        @valid_attrs
        |> Map.put(:phase_id, phase.id)
        |> Map.put(:team_stats, [
          %{team_id: second_team_stats_second_elimination.team_id},
          %{team_id: first_team_stats_second_elimination.team_id}
        ])
        |> Eliminations.create_elimination()

      assert :ok = Phases.generate_phase_results(phase.id)

      [wins_stat, losses_stat, points_stat] = phase.elimination_stats

      updated_first_elimination = Eliminations.get_elimination!(first_elimination.id)

      [first_team_stats, second_team_stats] = updated_first_elimination.team_stats

      assert first_team_stats.team_id == first_team_stats_first_elimination.team_id
      assert first_team_stats.stats[wins_stat.id] == 7
      assert first_team_stats.stats[losses_stat.id] == 4
      assert first_team_stats.stats[points_stat.id] == 15

      assert second_team_stats.team_id == second_team_stats_first_elimination.team_id
      assert second_team_stats.stats[wins_stat.id] == 7
      assert second_team_stats.stats[losses_stat.id] == 3
      assert second_team_stats.stats[points_stat.id] == 10

      updated_second_elimination = Eliminations.get_elimination!(second_elimination.id)

      [first_team_stats, second_team_stats] = updated_second_elimination.team_stats

      assert first_team_stats.team_id == first_team_stats_second_elimination.team_id
      assert first_team_stats.stats[wins_stat.id] == 10
      assert first_team_stats.stats[losses_stat.id] == 0
      assert first_team_stats.stats[points_stat.id] == 50

      assert second_team_stats.team_id == second_team_stats_second_elimination.team_id
      assert second_team_stats.stats[wins_stat.id] == 7
      assert second_team_stats.stats[losses_stat.id] == 3
      assert second_team_stats.stats[points_stat.id] == 40
    end

    test "for draw, returns :ok and update draw matches" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()

      phase = PhaseHelpers.create_phase(%{tournament_id: tournament.id, type: "draw"})

      {:ok, first_team_head_to_head_stats_log} =
        %{tournament_id: tournament.id, phase_id: phase.id, stats: %{"wins" => 3}}
        |> TeamHelpers.map_team_id_in_attrs()
        |> TeamHelpers.map_against_team_id()
        |> AggregatedTeamHeadToHeadStatsByPhases.create_aggregated_team_head_to_head_stats_by_phase()

      {:ok, second_team_head_to_head_stats_log} =
        %{
          tournament_id: tournament.id,
          phase_id: phase.id,
          stats: %{"wins" => 2},
          team_id: first_team_head_to_head_stats_log.against_team_id,
          against_team_id: first_team_head_to_head_stats_log.team_id
        }
        |> AggregatedTeamHeadToHeadStatsByPhases.create_aggregated_team_head_to_head_stats_by_phase()

      {:ok, draw} =
        %{
          phase_id: phase.id,
          matches: [
            %{
              first_team_id: first_team_head_to_head_stats_log.team_id,
              first_team_score: "0",
              info: "Match Info",
              name: "Match Name",
              second_team_id: second_team_head_to_head_stats_log.team_id,
              second_team_score: "0"
            }
          ]
        }
        |> Draws.create_draw()

      assert :ok = Phases.generate_phase_results(phase.id)

      updated_draw = Draws.get_draw!(draw.id)
      [match] = updated_draw.matches
      assert match.first_team_score == "3"
      assert match.second_team_score == "2"
    end
  end
end
