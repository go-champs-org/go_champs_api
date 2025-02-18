defmodule GoChampsApi.EliminationsTest do
  alias GoChampsApi.Eliminations.Elimination.TeamStats
  alias GoChampsApi.Helpers.AggregatedTeamStatsByPhaseHelper
  use GoChampsApi.DataCase

  alias GoChampsApi.Eliminations
  alias GoChampsApi.Helpers.PhaseHelpers

  alias GoChampsApi.Eliminations.Elimination
  alias GoChampsApi.Phases

  random_uuid = "d6a40c15-7363-4179-9f7b-8b17cc6cf32c"

  describe "eliminations" do
    @valid_attrs %{
      title: "some title",
      info: "some info",
      team_stats: [
        %{placeholder: "placeholder", team_id: random_uuid, stats: %{"key" => "value"}}
      ]
    }
    @update_attrs %{
      title: "some updated title",
      info: "some updated info",
      team_stats: [
        %{placeholder: "placeholder updated", team_id: random_uuid, stats: %{"key" => "updated"}}
      ]
    }
    @invalid_attrs %{team_stats: nil}

    def elimination_fixture(attrs \\ %{}) do
      {:ok, elimination} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PhaseHelpers.map_phase_id()
        |> Eliminations.create_elimination()

      elimination
    end

    test "get_elimination!/1 returns the elimination with given id" do
      elimination = elimination_fixture()

      assert Eliminations.get_elimination!(elimination.id) == elimination
    end

    test "get_elimination_organization/1 returns the organization with a give team id" do
      elimination = elimination_fixture()

      organization = Eliminations.get_elimination_organization!(elimination.id)

      elimination_organization = Phases.get_phase_organization!(elimination.phase_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == elimination_organization.id
    end

    test "get_eliminations_phase_id/1 with valid data return pertaning phase" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)

      {:ok, %Elimination{} = first_elimination} = Eliminations.create_elimination(attrs)
      {:ok, %Elimination{} = second_elimination} = Eliminations.create_elimination(attrs)

      first_updated_elimination = %{
        "id" => first_elimination.id,
        "title" => "some first updated title"
      }

      second_updated_elimination = %{
        "id" => second_elimination.id,
        "title" => "some second updated title"
      }

      {:ok, phase_id} =
        Eliminations.get_eliminations_phase_id([
          first_updated_elimination,
          second_updated_elimination
        ])

      assert phase_id == attrs.phase_id
    end

    test "get_eliminations_phase_id/1 with multiple phase associated returns error" do
      first_attrs = PhaseHelpers.map_phase_id(@valid_attrs)
      phase = Phases.get_phase!(first_attrs.phase_id)

      {:ok, second_phase} =
        Phases.create_phase(%{
          title: "some other title",
          type: "elimination",
          is_in_progress: true,
          tournament_id: phase.tournament_id
        })

      second_attrs = Map.merge(@valid_attrs, %{phase_id: second_phase.id})

      {:ok, %Elimination{} = first_elimination} = Eliminations.create_elimination(first_attrs)
      {:ok, %Elimination{} = second_elimination} = Eliminations.create_elimination(second_attrs)

      first_updated_elimination = %{
        "id" => first_elimination.id,
        "title" => "some first updated title"
      }

      second_updated_elimination = %{
        "id" => second_elimination.id,
        "title" => "some second updated title"
      }

      assert {:error, "Can only update elimination from same phase"} =
               Eliminations.get_eliminations_phase_id([
                 first_updated_elimination,
                 second_updated_elimination
               ])
    end

    test "create_elimination/1 with valid data creates a elimination" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)
      assert {:ok, %Elimination{} = elimination} = Eliminations.create_elimination(attrs)

      assert elimination.title == "some title"
      assert elimination.info == "some info"
      assert elimination.order == 1
      [team_stat] = elimination.team_stats
      assert team_stat.placeholder == "placeholder"
      assert team_stat.team_id == "d6a40c15-7363-4179-9f7b-8b17cc6cf32c"
      assert team_stat.stats == %{"key" => "value"}
    end

    test "create_elimination/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Eliminations.create_elimination(@invalid_attrs)
    end

    test "create_elimination/1 select order for second item" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)

      assert {:ok, %Elimination{} = first_elimination} = Eliminations.create_elimination(attrs)

      assert {:ok, %Elimination{} = second_elimination} = Eliminations.create_elimination(attrs)

      assert first_elimination.order == 1
      assert second_elimination.order == 2
    end

    test "create_elimination/1 set order as 1 for new elimination" do
      first_attrs = PhaseHelpers.map_phase_id(@valid_attrs)

      assert {:ok, %Elimination{} = first_elimination} =
               Eliminations.create_elimination(first_attrs)

      phase = Phases.get_phase!(first_elimination.phase_id)

      {:ok, second_phase} =
        Phases.create_phase(%{
          is_in_progress: true,
          title: "some title",
          type: "elimination",
          elimination_stats: [%{"title" => "stat title"}],
          tournament_id: phase.tournament_id
        })

      second_attrs = %{
        title: "some title",
        info: "some info",
        team_stats: [
          %{placeholder: "placeholder", team_id: "team-id", stats: %{"key" => "value"}}
        ],
        phase_id: second_phase.id
      }

      assert {:ok, %Elimination{} = second_elimination} =
               Eliminations.create_elimination(second_attrs)

      assert first_elimination.order == 1
      assert second_elimination.order == 1
    end

    test "update_elimination/2 with valid data updates the elimination" do
      elimination = elimination_fixture()

      assert {:ok, %Elimination{} = elimination} =
               Eliminations.update_elimination(elimination, @update_attrs)

      assert elimination.title == "some updated title"
      assert elimination.info == "some updated info"
      [team_stat] = elimination.team_stats
      assert team_stat.placeholder == "placeholder updated"
      assert team_stat.team_id == "d6a40c15-7363-4179-9f7b-8b17cc6cf32c"
      assert team_stat.stats == %{"key" => "updated"}
    end

    test "update_elimination/2 with invalid data returns error changeset" do
      elimination = elimination_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Eliminations.update_elimination(elimination, @invalid_attrs)

      assert elimination ==
               Eliminations.get_elimination!(elimination.id)
    end

    test "update_eliminations/2 with valid data updates the phase" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)

      {:ok, %Elimination{} = first_elimination} = Eliminations.create_elimination(attrs)
      {:ok, %Elimination{} = second_elimination} = Eliminations.create_elimination(attrs)

      first_updated_elimination = %{
        "id" => first_elimination.id,
        "title" => "some first updated title"
      }

      second_updated_elimination = %{
        "id" => second_elimination.id,
        "title" => "some second updated title"
      }

      {:ok, batch_results} =
        Eliminations.update_eliminations([first_updated_elimination, second_updated_elimination])

      assert batch_results[first_elimination.id].id == first_elimination.id
      assert batch_results[first_elimination.id].title == "some first updated title"
      assert batch_results[second_elimination.id].id == second_elimination.id
      assert batch_results[second_elimination.id].title == "some second updated title"
    end

    test "delete_elimination/1 deletes the elimination" do
      elimination = elimination_fixture()
      assert {:ok, %Elimination{}} = Eliminations.delete_elimination(elimination)

      assert_raise Ecto.NoResultsError, fn ->
        Eliminations.get_elimination!(elimination.id)
      end
    end

    test "change_elimination/1 returns a elimination changeset" do
      elimination = elimination_fixture()
      assert %Ecto.Changeset{} = Eliminations.change_elimination(elimination)
    end
  end

  describe "sort_team_stats_based_on_phase_criteria/1" do
    test "sorts team stats by ranking order" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()
      team_id_3 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 8, "points" => 8}},
            %{team_id: team_id_2, stats: %{"wins" => 10, "points" => 5}},
            %{team_id: team_id_3, stats: %{"wins" => 8, "points" => 10}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, _phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1},
          %{"title" => "Points", "team_stat_source" => "points", "ranking_order" => 2}
        ])

      {:ok, result_elimination} =
        Eliminations.sort_team_stats_based_on_phase_criteria(elimination.id)

      [first_team_stat, second_team_stat, third_team_stat] = result_elimination.team_stats

      assert first_team_stat.team_id == team_id_2
      assert second_team_stat.team_id == team_id_3
      assert third_team_stat.team_id == team_id_1
    end

    test "sorts team stats by ranking order with negative stats values" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()
      team_id_3 = Ecto.UUID.autogenerate()
      team_id_4 = Ecto.UUID.autogenerate()
      team_id_5 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 0, "points_balance" => -64}},
            %{team_id: team_id_4, stats: %{"wins" => 1, "points_balance" => -44}},
            %{team_id: team_id_3, stats: %{"wins" => 1, "points_balance" => 55}},
            %{team_id: team_id_5, stats: %{"wins" => 2, "points_balance" => 13}},
            %{team_id: team_id_2, stats: %{"wins" => 0, "points_balance" => -12}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, _phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1},
          %{
            "title" => "Points Balance",
            "team_stat_source" => "points_balance",
            "ranking_order" => 2
          }
        ])

      {:ok, result_elimination} =
        Eliminations.sort_team_stats_based_on_phase_criteria(elimination.id)

      [first_team_stat, second_team_stat, third_team_stat, fourth_team_stat, fifth_team_stat] =
        result_elimination.team_stats

      assert first_team_stat.team_id == team_id_5
      assert second_team_stat.team_id == team_id_3
      assert third_team_stat.team_id == team_id_4
      assert fourth_team_stat.team_id == team_id_2
      assert fifth_team_stat.team_id == team_id_1
    end
  end

  describe "should_team_stats_a_be_placed_before_team_stats_b?/3" do
    test "returns true if team stats a should be placed before team stats b based on phase criteria ranking order 1" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 12, "points" => 8}},
            %{team_id: team_id_2, stats: %{"wins" => 10, "points" => 5}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1},
          %{"title" => "Points", "team_stat_source" => "points", "ranking_order" => 2}
        ])

      [team_stat_a, team_stat_b] = elimination.team_stats

      assert Eliminations.should_team_stats_a_be_placed_before_team_stats_b?(
               phase,
               team_stat_a,
               team_stat_b
             )
    end

    test "returns false if team stats a should not be placed before team stats b based on phase criteria" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 6, "points" => 5}},
            %{team_id: team_id_2, stats: %{"wins" => 8, "points" => 8}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1},
          %{"title" => "Points", "team_stat_source" => "points", "ranking_order" => 2}
        ])

      [team_stat_a, team_stat_b] = elimination.team_stats

      refute Eliminations.should_team_stats_a_be_placed_before_team_stats_b?(
               phase,
               team_stat_a,
               team_stat_b
             )
    end

    test "returns true if team stats a should be placed before team stats b based on phase criteria ranking order 2" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 8, "points" => 10}},
            %{team_id: team_id_2, stats: %{"wins" => 8, "points" => 8}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1},
          %{"title" => "Points", "team_stat_source" => "points", "ranking_order" => 2}
        ])

      [team_stat_a, team_stat_b] = elimination.team_stats

      assert Eliminations.should_team_stats_a_be_placed_before_team_stats_b?(
               phase,
               team_stat_a,
               team_stat_b
             )
    end

    test "returns false if team stats a should not be placed before team stats b based on phase criteria ranking order 2" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 8, "points" => 8}},
            %{team_id: team_id_2, stats: %{"wins" => 8, "points" => 10}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1},
          %{"title" => "Points", "team_stat_source" => "points", "ranking_order" => 2}
        ])

      [team_stat_a, team_stat_b] = elimination.team_stats

      refute Eliminations.should_team_stats_a_be_placed_before_team_stats_b?(
               phase,
               team_stat_a,
               team_stat_b
             )
    end

    test "returns false if team stats a should not be placed before team stats b based on phase criteria ranking order 2 even with losing in ranking order 3" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 8, "points" => 10, "average" => 3}},
            %{team_id: team_id_2, stats: %{"wins" => 8, "points" => 8, "average" => 5}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Points", "team_stat_source" => "points", "ranking_order" => 3},
          %{"title" => "Average", "team_stat_source" => "average", "ranking_order" => 2},
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 1}
        ])

      [team_stat_a, team_stat_b] = elimination.team_stats

      refute Eliminations.should_team_stats_a_be_placed_before_team_stats_b?(
               phase,
               team_stat_a,
               team_stat_b
             )
    end

    test "returns true when ranking order is not defined" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 12}},
            %{team_id: team_id_2, stats: %{"wins" => 10}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins"}
        ])

      [team_stat_a, team_stat_b] = elimination.team_stats

      assert Eliminations.should_team_stats_a_be_placed_before_team_stats_b?(
               phase,
               team_stat_a,
               team_stat_b
             )
    end

    test "returns true when ranking order is 0" do
      team_id_1 = Ecto.UUID.autogenerate()
      team_id_2 = Ecto.UUID.autogenerate()

      elimination =
        elimination_fixture(%{
          team_stats: [
            %{team_id: team_id_1, stats: %{"wins" => 12}},
            %{team_id: team_id_2, stats: %{"wins" => 10}}
          ]
        })

      # Phase should sort by wins first and then by points
      {:ok, phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins", "ranking_order" => 0}
        ])

      [team_stat_a, team_stat_b] = elimination.team_stats

      assert Eliminations.should_team_stats_a_be_placed_before_team_stats_b?(
               phase,
               team_stat_a,
               team_stat_b
             )
    end
  end

  describe "update_team_stats_from_aggregated_team_stats_by_phase/1" do
    test "generate stats keys based on the phase elimination_stats and the values based on AggregateTeamStatsByPhase" do
      aggregated_team_stats_by_phase =
        AggregatedTeamStatsByPhaseHelper.create_aggregated_team_stats_by_phase(%{
          "wins" => 7,
          "losses" => 3
        })

      {:ok, phase} =
        aggregated_team_stats_by_phase.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Wins", "team_stat_source" => "wins"},
          %{"title" => "Losses", "team_stat_source" => "losses"}
        ])

      {:ok, elimination} =
        @valid_attrs
        |> Map.put(:phase_id, phase.id)
        |> Map.put(:team_stats, [%{team_id: aggregated_team_stats_by_phase.team_id}])
        |> Eliminations.create_elimination()

      {:ok, result_elimination} =
        Eliminations.update_team_stats_from_aggregated_team_stats_by_phase(elimination.id)

      [team_elimination_stats] = result_elimination.team_stats

      [wins_stat, losses_stat] = phase.elimination_stats

      assert team_elimination_stats.stats[wins_stat.id] == 7
      assert team_elimination_stats.stats[losses_stat.id] == 3
    end
  end

  describe "update_stats_values_from_aggregated_team_stats_by_phase/2" do
    test "update stats values based on phase elimination_stats and AggregatedTeamStatsByPhase values for a given TeamStats" do
      aggregate_team_stats_by_phase =
        AggregatedTeamStatsByPhaseHelper.create_aggregated_team_stats_by_phase(%{
          "points" => 10,
          "points_against" => 5
        })

      team_stat = %TeamStats{
        team_id: aggregate_team_stats_by_phase.team_id
      }

      {:ok, phase} =
        aggregate_team_stats_by_phase.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Points", "team_stat_source" => "points"},
          %{"title" => "Points against", "team_stat_source" => "points_against"}
        ])

      updated_team_stat =
        Eliminations.update_stats_values_from_aggregated_team_stats_by_phase(team_stat, phase)

      [points_stat, points_against_stat] = phase.elimination_stats

      assert updated_team_stat.stats[points_stat.id] == 10
      assert updated_team_stat.stats[points_against_stat.id] == 5
    end

    test "does not update stats value when there is no AggregatedTeamStatsByPhase" do
      team_stat = %TeamStats{
        team_id: Ecto.UUID.autogenerate(),
        stats: %{"some" => "value"}
      }

      {:ok, elimination} =
        @valid_attrs
        |> PhaseHelpers.map_phase_id()
        |> Map.put(:team_stats, [%{team_id: team_stat.team_id}])
        |> Eliminations.create_elimination()

      {:ok, phase} =
        elimination.phase_id
        |> PhaseHelpers.set_elimination_stats([
          %{"title" => "Points", "team_stat_source" => "points"},
          %{"title" => "Points against", "team_stat_source" => "points_against"}
        ])

      updated_team_stat =
        Eliminations.update_stats_values_from_aggregated_team_stats_by_phase(team_stat, phase)

      assert updated_team_stat.stats == %{"some" => "value"}
    end
  end

  describe "retrive_stat_value/2" do
    test "returns stat value from AggregatedTeamStatsByPhase values for a given team stat source" do
      aggregate_team_stats_by_phase =
        AggregatedTeamStatsByPhaseHelper.create_aggregated_team_stats_by_phase(%{
          "kills" => 10,
          "deaths" => 5
        })

      assert Eliminations.retrive_stat_value(aggregate_team_stats_by_phase, "kills") == 10
      assert Eliminations.retrive_stat_value(aggregate_team_stats_by_phase, "deaths") == 5
    end

    test "returns 0 if the stat value is not found" do
      aggregate_team_stats_by_phase =
        AggregatedTeamStatsByPhaseHelper.create_aggregated_team_stats_by_phase(%{
          "kills" => 10,
          "deaths" => 5
        })

      assert Eliminations.retrive_stat_value(aggregate_team_stats_by_phase, "assists") == 0
    end
  end
end
