defmodule GoChampsApi.TeamStatsLogsTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.TeamStatsLogs
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.PendingAggregatedTeamStatsByPhases
  alias GoChampsApi.Phases

  describe "team_stats_log" do
    alias GoChampsApi.Phases.Phase
    alias GoChampsApi.TeamStatsLogs.TeamStatsLog

    @valid_attrs %{stats: %{"some" => "some"}}
    @update_attrs %{stats: %{"some" => "some updated"}}
    @invalid_attrs %{datetime: nil, stats: nil}

    def team_stats_log_fixture(attrs \\ %{}) do
      {:ok, team_stats_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TeamHelpers.map_team_id_and_tournament_id()
        |> PhaseHelpers.map_phase_id_for_tournament()
        |> TeamStatsLogs.create_team_stats_log()

      team_stats_log
    end

    test "list_team_stats_log/0 returns all team_stats_log" do
      team_stats_log = team_stats_log_fixture()
      assert TeamStatsLogs.list_team_stats_log() == [team_stats_log]
    end

    test "list_team_stats_log/1 returns all tournaments pertaining to some game id" do
      first_valid_attrs =
        TeamHelpers.map_team_id_and_tournament_id(@valid_attrs)
        |> PhaseHelpers.map_phase_id_for_tournament()

      phase_attrs = %{
        is_in_progress: true,
        title: "some title",
        type: "elimination",
        elimination_stats: [%{"title" => "stat title"}],
        tournament_id: first_valid_attrs.tournament_id
      }

      assert {:ok, %Phase{} = phase} = Phases.create_phase(phase_attrs)

      second_valid_attrs =
        @valid_attrs
        |> Map.merge(%{
          team_id: first_valid_attrs.team_id,
          tournament_id: first_valid_attrs.tournament_id,
          phase_id: phase.id
        })

      assert {:ok, batch_results} =
               TeamStatsLogs.create_team_stats_logs([first_valid_attrs, second_valid_attrs])

      where = [phase_id: phase.id]
      assert TeamStatsLogs.list_team_stats_log(where) == [batch_results[1]]
    end

    test "get_team_stats_log!/1 returns the team_stats_log with given id" do
      team_stats_log = team_stats_log_fixture()
      assert TeamStatsLogs.get_team_stats_log!(team_stats_log.id) == team_stats_log
    end

    test "get_team_stats_log_organization!/1 returns the organization with a give team id" do
      team_stats_log = team_stats_log_fixture()

      organization = TeamStatsLogs.get_team_stats_log_organization!(team_stats_log.id)

      tournament = Tournaments.get_tournament!(team_stats_log.tournament_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "create_team_stats_log/1 with valid data creates a team_stats_log" do
      valid_attrs =
        TeamHelpers.map_team_id_and_tournament_id(@valid_attrs)
        |> PhaseHelpers.map_phase_id_for_tournament()

      assert {:ok, %TeamStatsLog{} = team_stats_log} =
               TeamStatsLogs.create_team_stats_log(valid_attrs)

      assert team_stats_log.stats == %{
               "some" => "some"
             }

      [pending_aggregated_team_stats_by_phase] =
        PendingAggregatedTeamStatsByPhases.list_pending_aggregated_team_stats_by_phase()

      assert pending_aggregated_team_stats_by_phase.tournament_id ==
               team_stats_log.tournament_id

      assert pending_aggregated_team_stats_by_phase.phase_id ==
               team_stats_log.phase_id
    end

    test "create_team_stats_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TeamStatsLogs.create_team_stats_log(@invalid_attrs)
    end

    test "create_team_stats_logs/1 with valid data creates a team_stats_log and creates a team_stats_log and add pending aggregated team stats" do
      first_valid_attrs =
        TeamHelpers.map_team_id_and_tournament_id(@valid_attrs)
        |> PhaseHelpers.map_phase_id_for_tournament()

      second_valid_attrs =
        @valid_attrs
        |> Map.merge(%{
          phase_id: first_valid_attrs.phase_id,
          team_id: first_valid_attrs.team_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      assert {:ok, batch_results} =
               TeamStatsLogs.create_team_stats_logs([first_valid_attrs, second_valid_attrs])

      assert batch_results[0].team_id == first_valid_attrs.team_id
      assert batch_results[0].tournament_id == first_valid_attrs.tournament_id

      assert batch_results[0].stats == %{
               "some" => "some"
             }

      assert batch_results[1].team_id == first_valid_attrs.team_id
      assert batch_results[1].tournament_id == first_valid_attrs.tournament_id

      assert batch_results[1].stats == %{
               "some" => "some"
             }

      [pending_aggregated_team_stats_by_phase] =
        PendingAggregatedTeamStatsByPhases.list_pending_aggregated_team_stats_by_phase()

      assert pending_aggregated_team_stats_by_phase.tournament_id ==
               batch_results[0].tournament_id
    end

    test "update_team_stats_log/2 with valid data updates the team_stats_log and creates a team_stats_log and add pending aggregated team stats" do
      team_stats_log = team_stats_log_fixture()

      assert {:ok, %TeamStatsLog{} = team_stats_log} =
               TeamStatsLogs.update_team_stats_log(team_stats_log, @update_attrs)

      assert team_stats_log.stats == %{
               "some" => "some updated"
             }

      # In this test we are calling create_team_stats_log once to set
      # the test up, that why we need to assert if only have 2 cause the
      # update should only add it once.
      assert Enum.count(
               PendingAggregatedTeamStatsByPhases.list_pending_aggregated_team_stats_by_phase()
             ) == 2

      # assert PendingAggregatedTeamStatsByPhases.list_phases_ids() == [
      #          team_stats_log.phase_id
      #        ]
    end

    test "update_team_stats_log/2 with invalid data returns error changeset" do
      team_stats_log = team_stats_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               TeamStatsLogs.update_team_stats_log(team_stats_log, @invalid_attrs)

      assert team_stats_log == TeamStatsLogs.get_team_stats_log!(team_stats_log.id)
    end

    test "update_team_stats_logs/1 with valid data updates the team_stats_log and creates a team_stats_log and add pending aggregated team stats" do
      attrs =
        TeamHelpers.map_team_id_and_tournament_id(@valid_attrs)
        |> PhaseHelpers.map_phase_id_for_tournament()

      {:ok, %TeamStatsLog{} = first_team_stats_log} = TeamStatsLogs.create_team_stats_log(attrs)

      {:ok, %TeamStatsLog{} = second_team_stats_log} = TeamStatsLogs.create_team_stats_log(attrs)

      first_updated_team_stats_log = %{
        "id" => first_team_stats_log.id,
        "stats" => %{"some" => "some first updated"}
      }

      second_updated_team_stats_log = %{
        "id" => second_team_stats_log.id,
        "stats" => %{"some" => "some second updated"}
      }

      {:ok, batch_results} =
        TeamStatsLogs.update_team_stats_logs([
          first_updated_team_stats_log,
          second_updated_team_stats_log
        ])

      assert batch_results[first_team_stats_log.id].id == first_team_stats_log.id

      assert batch_results[first_team_stats_log.id].stats == %{
               "some" => "some first updated"
             }

      assert batch_results[second_team_stats_log.id].id == second_team_stats_log.id

      assert batch_results[second_team_stats_log.id].stats == %{
               "some" => "some second updated"
             }

      # In this test we are calling create_team_stats_log twice to set
      # the test up, that why we need to assert if only have 3 cause the
      # update should only add it once.
      assert Enum.count(
               PendingAggregatedTeamStatsByPhases.list_pending_aggregated_team_stats_by_phase()
             ) == 3

      # assert PendingAggregatedTeamStatsByPhases.list_tournament_ids() == [
      #          attrs.tournament_id
      #        ]
    end

    test "delete_team_stats_log/1 deletes the team_stats_log" do
      team_stats_log = team_stats_log_fixture()
      assert {:ok, %TeamStatsLog{}} = TeamStatsLogs.delete_team_stats_log(team_stats_log)

      assert_raise Ecto.NoResultsError, fn ->
        TeamStatsLogs.get_team_stats_log!(team_stats_log.id)
      end

      # In this test we are calling create_team_stats_log once to set
      # the test up, that why we need to assert if only have 2 cause the
      # update should only add it once.
      assert Enum.count(
               PendingAggregatedTeamStatsByPhases.list_pending_aggregated_team_stats_by_phase()
             ) == 2

      # assert PendingAggregatedTeamStatsByPhases.list_tournament_ids() == [
      #          team_stats_log.tournament_id
      #        ]
    end

    test "change_team_stats_log/1 returns a team_stats_log changeset" do
      team_stats_log = team_stats_log_fixture()
      assert %Ecto.Changeset{} = TeamStatsLogs.change_team_stats_log(team_stats_log)
    end
  end
end
