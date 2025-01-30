defmodule GoChampsApi.PlayerStatsLogsTest do
  use GoChampsApi.DataCase
  import Mox

  alias GoChampsApi.Helpers.TournamentHelpers

  alias GoChampsApi.PlayerStatsLogs
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Helpers.PlayerHelpers
  alias GoChampsApi.PendingAggregatedPlayerStatsByTournaments
  alias GoChampsApi.Phases
  alias GoChampsApi.TaskSupervisorMock

  setup :verify_on_exit!

  # setup do
  #   Application.put_env(:go_champs_api, :task_supervisor, TaskSupervisorMock)
  #   :ok
  # end

  describe "player_stats_log" do
    alias GoChampsApi.Phases.Phase
    alias GoChampsApi.PlayerStatsLogs.PlayerStatsLog

    @valid_attrs %{stats: %{"some" => "some"}}
    @update_attrs %{stats: %{"some" => "some updated"}}
    @invalid_attrs %{datetime: nil, stats: nil}

    def player_stats_log_fixture(attrs \\ %{}) do
      {:ok, player_stats_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PlayerHelpers.map_player_id_and_tournament_id()
        |> PlayerStatsLogs.create_player_stats_log()

      player_stats_log
    end

    def player_stats_log_for_tournament_with_sport(player_stats_values \\ []) do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()
      {:ok, player} = PlayerHelpers.create_player_for_tournament(tournament.id)

      player_stats =
        Enum.reduce(player_stats_values, %{}, fn {player_stat_slug, value}, acc ->
          Map.put(acc, player_stat_slug, value)
        end)

      {:ok, player_stats_log} =
        %{
          player_id: player.id,
          tournament_id: tournament.id,
          stats: player_stats
        }
        |> PlayerStatsLogs.create_player_stats_log()

      player_stats_log
    end

    test "list_player_stats_log/0 returns all player_stats_log" do
      player_stats_log = player_stats_log_fixture()
      assert PlayerStatsLogs.list_player_stats_log() == [player_stats_log]
    end

    test "list_player_stats_log/1 returns all tournaments pertaining to some game id" do
      first_valid_attrs = PlayerHelpers.map_player_id_and_tournament_id(@valid_attrs)

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
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id,
          phase_id: phase.id
        })

      assert {:ok, batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      where = [phase_id: phase.id]
      assert PlayerStatsLogs.list_player_stats_log(where) == [batch_results[1]]
    end

    test "get_player_stats_log!/1 returns the player_stats_log with given id" do
      player_stats_log = player_stats_log_fixture()
      assert PlayerStatsLogs.get_player_stats_log!(player_stats_log.id) == player_stats_log
    end

    test "get_player_stats_log_organization!/1 returns the organization with a give player id" do
      player_stats_log = player_stats_log_fixture()

      organization = PlayerStatsLogs.get_player_stats_log_organization!(player_stats_log.id)

      tournament = Tournaments.get_tournament!(player_stats_log.tournament_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "create_player_stats_log/1 with valid data and creates a player_stats_log and add pending aggregated player stats" do
      expect(TaskSupervisorMock, :start_child, fn _args, _fn -> :ok end)
      valid_attrs = PlayerHelpers.map_player_id_and_tournament_id(@valid_attrs)

      assert {:ok, %PlayerStatsLog{} = player_stats_log} =
               PlayerStatsLogs.create_player_stats_log(valid_attrs)

      assert player_stats_log.stats == %{
               "some" => "some"
             }

      [pending_aggregated_player_stats_by_tournament] =
        PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament()

      assert pending_aggregated_player_stats_by_tournament.tournament_id ==
               player_stats_log.tournament_id
    end

    test "create_player_stats_log/1 with valid data that matches tournament player stats slugs creates a player_stats_log with slug stats and add pending aggregated player stats" do
      valid_attrs = PlayerHelpers.map_player_id_and_tournament_id(%{})

      tournament = Tournaments.get_tournament!(valid_attrs.tournament_id)

      tournament_player_stats = [
        %{
          "title" => "Def Reboundos",
          "slug" => "def_rebounds"
        },
        %{
          "title" => "Assists",
          "slug" => "assists"
        }
      ]

      {:ok, tournament} =
        Tournaments.update_tournament(tournament, %{player_stats: tournament_player_stats})

      def_rebounds_player_stat = Tournaments.get_player_stat_by_slug!(tournament, "def_rebounds")
      assists_player_stat = Tournaments.get_player_stat_by_slug!(tournament, "assists")

      valid_attrs =
        Map.merge(valid_attrs, %{
          stats: %{
            def_rebounds_player_stat.id => 10,
            assists_player_stat.id => 5
          }
        })

      assert {:ok, %PlayerStatsLog{} = player_stats_log} =
               PlayerStatsLogs.create_player_stats_log(valid_attrs)

      assert player_stats_log.stats[def_rebounds_player_stat.slug] == "10"
      assert player_stats_log.stats[assists_player_stat.slug] == "5"

      [pending_aggregated_player_stats_by_tournament] =
        PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament()

      assert pending_aggregated_player_stats_by_tournament.tournament_id ==
               player_stats_log.tournament_id
    end

    test "create_player_stats_log/1 with valid data that matches tournament sport statistics store result of calculated stats" do
      player_stats_log =
        player_stats_log_for_tournament_with_sport([
          {"rebounds_defensive", "10"},
          {"rebounds_offensive", "5"}
        ])

      assert player_stats_log.stats["rebounds"] == "15.0"
      assert player_stats_log.stats["rebounds_defensive"] == "10"
      assert player_stats_log.stats["rebounds_offensive"] == "5"
    end

    test "create_player_stats_log/1 with valid data that matches tournament player stats with no slug creates a player_stats_log with id stats and add pending aggregated player stats" do
      valid_attrs = PlayerHelpers.map_player_id_and_tournament_id(%{})

      tournament = Tournaments.get_tournament!(valid_attrs.tournament_id)

      tournament_player_stats = [
        %{
          "title" => "Def Reboundos"
        },
        %{
          "title" => "Assists"
        }
      ]

      {:ok, tournament} =
        Tournaments.update_tournament(tournament, %{player_stats: tournament_player_stats})

      [def_rebounds_player_stat, assists_player_stat] = tournament.player_stats

      valid_attrs =
        Map.merge(valid_attrs, %{
          stats: %{
            def_rebounds_player_stat.id => 10,
            assists_player_stat.id => 5
          }
        })

      assert {:ok, %PlayerStatsLog{} = player_stats_log} =
               PlayerStatsLogs.create_player_stats_log(valid_attrs)

      assert player_stats_log.stats[def_rebounds_player_stat.id] == "10"
      assert player_stats_log.stats[assists_player_stat.id] == "5"

      [pending_aggregated_player_stats_by_tournament] =
        PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament()

      assert pending_aggregated_player_stats_by_tournament.tournament_id ==
               player_stats_log.tournament_id
    end

    test "create_player_stats_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PlayerStatsLogs.create_player_stats_log(@invalid_attrs)
    end

    test "create_player_stats_logs/1 with valid data creates a player_stats_log and add pending aggregated player stats" do
      first_valid_attrs = PlayerHelpers.map_player_id_and_tournament_id(@valid_attrs)

      second_valid_attrs =
        @valid_attrs
        |> Map.merge(%{
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      assert {:ok, batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      assert batch_results[0].player_id == first_valid_attrs.player_id
      assert batch_results[0].tournament_id == first_valid_attrs.tournament_id

      assert batch_results[0].stats == %{
               "some" => "some"
             }

      assert batch_results[1].player_id == first_valid_attrs.player_id
      assert batch_results[1].tournament_id == first_valid_attrs.tournament_id

      assert batch_results[1].stats == %{
               "some" => "some"
             }

      [pending_aggregated_player_stats_by_tournament] =
        PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament()

      assert pending_aggregated_player_stats_by_tournament.tournament_id ==
               batch_results[0].tournament_id
    end

    test "update_player_stats_log/2 with valid data updates the player_stats_log and creates a player_stats_log and add pending aggregated player stats" do
      player_stats_log = player_stats_log_fixture()

      assert {:ok, %PlayerStatsLog{} = player_stats_log} =
               PlayerStatsLogs.update_player_stats_log(player_stats_log, @update_attrs)

      assert player_stats_log.stats == %{
               "some" => "some updated"
             }

      # In this test we are calling create_player_stats_log once to set
      # the test up, that why we need to assert if only have 2 cause the
      # update should only add it once.
      assert Enum.count(
               PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament()
             ) == 2

      assert PendingAggregatedPlayerStatsByTournaments.list_tournament_ids() == [
               player_stats_log.tournament_id
             ]
    end

    test "update_player_stats_log/2 with invalid data returns error changeset" do
      player_stats_log = player_stats_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PlayerStatsLogs.update_player_stats_log(player_stats_log, @invalid_attrs)

      assert player_stats_log == PlayerStatsLogs.get_player_stats_log!(player_stats_log.id)
    end

    test "update_player_stats_logs/1 with valid data updates the player_stats_log and creates a player_stats_log and add pending aggregated player stats" do
      attrs = PlayerHelpers.map_player_id_and_tournament_id(@valid_attrs)

      {:ok, %PlayerStatsLog{} = first_player_stats_log} =
        PlayerStatsLogs.create_player_stats_log(attrs)

      {:ok, %PlayerStatsLog{} = second_player_stats_log} =
        PlayerStatsLogs.create_player_stats_log(attrs)

      first_updated_player_stats_log = %{
        "id" => first_player_stats_log.id,
        "tournament_id" => first_player_stats_log.tournament_id,
        "stats" => %{"some" => "some first updated"}
      }

      second_updated_player_stats_log = %{
        "id" => second_player_stats_log.id,
        "tournament_id" => second_player_stats_log.tournament_id,
        "stats" => %{"some" => "some second updated"}
      }

      {:ok, batch_results} =
        PlayerStatsLogs.update_player_stats_logs([
          first_updated_player_stats_log,
          second_updated_player_stats_log
        ])

      assert batch_results[first_player_stats_log.id].id == first_player_stats_log.id

      assert batch_results[first_player_stats_log.id].stats == %{
               "some" => "some first updated"
             }

      assert batch_results[second_player_stats_log.id].id == second_player_stats_log.id

      assert batch_results[second_player_stats_log.id].stats == %{
               "some" => "some second updated"
             }

      # In this test we are calling create_player_stats_log twice to set
      # the test up, that why we need to assert if only have 3 cause the
      # update should only add it once.
      assert Enum.count(
               PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament()
             ) == 3

      assert PendingAggregatedPlayerStatsByTournaments.list_tournament_ids() == [
               attrs.tournament_id
             ]
    end

    test "delete_player_stats_log/1 deletes the player_stats_log" do
      player_stats_log = player_stats_log_fixture()
      assert {:ok, %PlayerStatsLog{}} = PlayerStatsLogs.delete_player_stats_log(player_stats_log)

      assert_raise Ecto.NoResultsError, fn ->
        PlayerStatsLogs.get_player_stats_log!(player_stats_log.id)
      end

      # In this test we are calling create_player_stats_log once to set
      # the test up, that why we need to assert if only have 2 cause the
      # update should only add it once.
      assert Enum.count(
               PendingAggregatedPlayerStatsByTournaments.list_pending_aggregated_player_stats_by_tournament()
             ) == 2

      assert PendingAggregatedPlayerStatsByTournaments.list_tournament_ids() == [
               player_stats_log.tournament_id
             ]
    end

    test "change_player_stats_log/1 returns a player_stats_log changeset" do
      player_stats_log = player_stats_log_fixture()
      assert %Ecto.Changeset{} = PlayerStatsLogs.change_player_stats_log(player_stats_log)
    end
  end
end
