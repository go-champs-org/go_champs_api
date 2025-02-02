defmodule GoChampsApi.PlayerStatsLogsTest do
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Helpers.GameHelpers
  alias GoChampsApi.Helpers.PlayerStatsLogHelper
  use GoChampsApi.DataCase
  use Oban.Testing, repo: GoChampsApi.Repo

  alias GoChampsApi.PlayerStatsLogs
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Tournaments.Tournament
  alias GoChampsApi.Helpers.PlayerHelpers
  alias GoChampsApi.Helpers.OrganizationHelpers
  alias GoChampsApi.Sports
  alias GoChampsApi.PendingAggregatedPlayerStatsByTournaments
  alias GoChampsApi.Phases

  describe "player_stats_log" do
    alias GoChampsApi.Phases.Phase
    alias GoChampsApi.PlayerStatsLogs.PlayerStatsLog

    @valid_attrs %{stats: %{"some" => "some"}}
    @update_attrs %{stats: %{"some" => "some updated"}}
    @invalid_attrs %{datetime: nil, stats: nil}
    @valid_tournament_attrs %{
      name: "some name",
      slug: "some-slug",
      player_stats: [
        %{
          title: "some stat"
        },
        %{
          title: "another stat"
        },
        %{
          title: "Total Rebounds",
          slug: "rebounds"
        },
        %{
          title: "Games Played",
          slug: "game_played"
        },
        %{
          title: "Total Rebounds defensive",
          slug: "rebounds_defensive"
        },
        %{
          title: "Total Rebounds offensive",
          slug: "rebounds_offensive"
        }
      ],
      sport_slug: "basketball_5x5"
    }

    def player_stats_log_fixture(attrs \\ %{}) do
      {:ok, player_stats_log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PlayerHelpers.map_player_id_and_tournament_id()
        |> PhaseHelpers.map_phase_id()
        |> GameHelpers.map_game_id()
        |> PlayerStatsLogs.create_player_stats_log()

      player_stats_log
    end

    test "list_player_stats_log/0 returns all player_stats_log" do
      player_stats_log = player_stats_log_fixture()
      assert PlayerStatsLogs.list_player_stats_log() == [player_stats_log]
    end

    test "list_player_stats_log/1 returns all player_stats_logs pertaining to some game id" do
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

    test "list_player_stats_log/1 returns all player_stats_logs that phase_id is nil" do
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

      where = [phase_id: nil]
      assert PlayerStatsLogs.list_player_stats_log(where) == [batch_results[0]]
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

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame,
        args: %{game_id: player_stats_log.game_id}
      )
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

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame,
        args: %{game_id: player_stats_log.game_id}
      )
    end

    test "create_player_stats_log/1 with valid data that matches tournament sport statistics store result of calculated stats" do
      player_stats_log =
        PlayerStatsLogHelper.create_player_stats_log_for_tournament_with_sport([
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

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame,
        args: %{game_id: player_stats_log.game_id}
      )
    end

    test "create_player_stats_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = PlayerStatsLogs.create_player_stats_log(@invalid_attrs)
    end

    test "create_player_stats_logs/1 with valid data creates a player_stats_log and add pending aggregated player stats" do
      first_valid_attrs = PlayerHelpers.map_player_id_and_tournament_id_and_game_id(@valid_attrs)

      second_valid_attrs =
        @valid_attrs
        |> Map.merge(%{
          game_id: first_valid_attrs.game_id,
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

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame,
        args: %{game_id: first_valid_attrs.game_id}
      )
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

      queue = all_enqueued(worker: GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame)
      # It needs to be two because we are calling create_player_stats_log once
      assert Enum.count(queue) == 2
      assert Enum.fetch!(queue, 1).args == %{"game_id" => player_stats_log.game_id}
    end

    test "update_player_stats_log/2 with invalid data returns error changeset" do
      player_stats_log = player_stats_log_fixture()

      assert {:error, %Ecto.Changeset{}} =
               PlayerStatsLogs.update_player_stats_log(player_stats_log, @invalid_attrs)

      assert player_stats_log == PlayerStatsLogs.get_player_stats_log!(player_stats_log.id)
    end

    test "update_player_stats_logs/1 with valid data updates the player_stats_log and creates a player_stats_log and add pending aggregated player stats" do
      attrs = PlayerHelpers.map_player_id_and_tournament_id_and_game_id(@valid_attrs)

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

      queue = all_enqueued(worker: GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame)
      # It needs to be three because we are calling create_player_stats_log twice
      assert Enum.count(queue) == 3
      assert Enum.fetch!(queue, 2).args == %{"game_id" => attrs.game_id}
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

      queue = all_enqueued(worker: GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame)
      # It needs to be two because we are calling create_player_stats_log once
      assert Enum.count(queue) == 2
      assert Enum.fetch!(queue, 1).args == %{"game_id" => player_stats_log.game_id}
    end

    test "change_player_stats_log/1 returns a player_stats_log changeset" do
      player_stats_log = player_stats_log_fixture()
      assert %Ecto.Changeset{} = PlayerStatsLogs.change_player_stats_log(player_stats_log)
    end

    test "aggregate_and_calculate_player_stats_from_player_stats_logs/1 returns a map with player stats aggregated and calculated" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            "rebounds_defensive" => "6",
            "rebounds_offensive" => "2"
          }
        })

      second_valid_attrs =
        %{
          stats: %{"rebounds_defensive" => "4", "rebounds_offensive" => "3"}
        }
        |> Map.merge(%{
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      player_stats_logs = PlayerStatsLogs.list_player_stats_log(tournament_id: tournament.id)

      result_stats =
        PlayerStatsLogs.aggregate_and_calculate_player_stats_from_player_stats_logs(
          player_stats_logs
        )

      assert result_stats["rebounds_defensive"] == 10.0
      assert result_stats["rebounds_offensive"] == 5.0
      assert result_stats["rebounds"] == 15.0
    end

    test "aggregate_player_stats_from_player_stats_logs/2 returns a map with player stats aggregated" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      [first_player_stat, second_player_stat | _tail] = tournament.player_stats

      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            first_player_stat.id => "6",
            second_player_stat.id => "2"
          }
        })

      second_valid_attrs =
        %{
          stats: %{first_player_stat.id => "4", second_player_stat.id => "3"}
        }
        |> Map.merge(%{
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      assert %{first_player_stat.id => 10.0, second_player_stat.id => 5.0} ==
               PlayerStatsLogs.aggregate_player_stats_from_player_stats_logs(
                 [first_player_stat.id, second_player_stat.id],
                 [first_valid_attrs, second_valid_attrs]
               )
    end

    test "aggregate_player_stats_from_player_stats_logs/2 returns a map with player stats aggregated when player stats has a string" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      [first_player_stat, second_player_stat | _tail] = tournament.player_stats

      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            first_player_stat.id => "six - points",
            second_player_stat.id => "2"
          }
        })

      second_valid_attrs =
        %{
          stats: %{first_player_stat.id => "4", second_player_stat.id => "3"}
        }
        |> Map.merge(%{
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      result_stats =
        PlayerStatsLogs.aggregate_player_stats_from_player_stats_logs(
          [first_player_stat.id, second_player_stat.id],
          [first_valid_attrs, second_valid_attrs]
        )

      assert result_stats[first_player_stat.id] == 4.0
      assert result_stats[second_player_stat.id] == 5.0
    end

    test "calculate_player_stats/2 returns a map with calculated statistics values" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            "rebounds" => "6",
            "game_played" => "1"
          }
        })

      second_valid_attrs =
        %{
          stats: %{"rebounds" => "4", "game_played" => "1"}
        }
        |> Map.merge(%{
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      aggregated_stats =
        PlayerStatsLogs.aggregate_player_stats_from_player_stats_logs(
          ["rebounds", "game_played"],
          [first_valid_attrs, second_valid_attrs]
        )

      calculated_player_stats =
        Sports.get_tournament_level_per_game_statistics!(tournament.sport_slug)

      result_stats =
        PlayerStatsLogs.calculate_player_stats(
          calculated_player_stats,
          aggregated_stats
        )

      assert result_stats["rebounds"] == 10.0
      assert result_stats["rebounds_per_game"] == 5.0
    end
  end
end
