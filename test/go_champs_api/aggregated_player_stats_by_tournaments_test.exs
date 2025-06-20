defmodule GoChampsApi.AggregatedPlayerStatsByTournamentsTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.AggregatedPlayerStatsByTournaments
  alias GoChampsApi.Players
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Helpers.OrganizationHelpers
  alias GoChampsApi.PlayerStatsLogs
  alias GoChampsApi.Helpers.PlayerHelpers

  describe "aggregated_player_stats_by_tournament" do
    alias GoChampsApi.Tournaments.Tournament
    alias GoChampsApi.AggregatedPlayerStatsByTournaments.AggregatedPlayerStatsByTournament

    @valid_attrs %{stats: %{"some" => "8"}}
    @update_attrs %{
      stats: %{"some" => "10"}
    }
    @invalid_attrs %{player_id: nil, stats: nil, tournament_id: nil}

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

    def aggregated_player_stats_by_tournament_fixture(attrs \\ %{}) do
      {:ok, aggregated_player_stats_by_tournament} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PlayerHelpers.map_player_id_and_tournament_id()
        |> AggregatedPlayerStatsByTournaments.create_aggregated_player_stats_by_tournament()

      aggregated_player_stats_by_tournament
    end

    test "list_aggregated_player_stats_by_tournament/0 returns all aggregated_player_stats_by_tournament" do
      aggregated_player_stats_by_tournament = aggregated_player_stats_by_tournament_fixture()

      assert AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament() == [
               aggregated_player_stats_by_tournament
             ]
    end

    test "list_aggregated_player_stats_by_tournament/0 returns all aggregated_player_stats_by_tournament pertaining to some tournament" do
      aggregated_player_stats_by_tournament = aggregated_player_stats_by_tournament_fixture()

      some_tournament =
        Tournaments.get_tournament!(aggregated_player_stats_by_tournament.tournament_id)

      {:ok, another_tournament} =
        %{name: "another tournament", slug: "another-slug"}
        |> Map.merge(%{
          organization_id: some_tournament.organization_id
        })
        |> Tournaments.create_tournament()

      valid_attrs =
        @valid_attrs
        |> Map.merge(%{
          tournament_id: another_tournament.id,
          player_id: aggregated_player_stats_by_tournament.player_id
        })

      {:ok, %AggregatedPlayerStatsByTournament{} = another_aggregated_player_stats_by_tournament} =
        AggregatedPlayerStatsByTournaments.create_aggregated_player_stats_by_tournament(
          valid_attrs
        )

      where = [tournament_id: another_tournament.id]

      assert AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament(where) ==
               [another_aggregated_player_stats_by_tournament]
    end

    test "list_aggregated_player_stats_by_tournament/0 returns all aggregated_player_stats_by_tournament ordered" do
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

      {:ok, second_player} =
        %{name: "another player"}
        |> Map.merge(%{tournament_id: tournament.id})
        |> Players.create_player()

      second_valid_attrs = %{
        stats: %{first_player_stat.id => "4", second_player_stat.id => "3"},
        player_id: second_player.id,
        tournament_id: first_valid_attrs.tournament_id
      }

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([second_valid_attrs, first_valid_attrs])

      AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      where = [tournament_id: tournament.id]

      [first_aggregated, second_aggregated] =
        AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament(
          where,
          first_player_stat.id
        )

      assert Map.fetch(first_aggregated.stats, first_player_stat.id) == {:ok, 6}
      assert Map.fetch(second_aggregated.stats, first_player_stat.id) == {:ok, 4}
    end

    test "get_aggregated_player_stats_by_tournament!/1 returns the aggregated_player_stats_by_tournament with given id" do
      aggregated_player_stats_by_tournament = aggregated_player_stats_by_tournament_fixture()

      assert AggregatedPlayerStatsByTournaments.get_aggregated_player_stats_by_tournament!(
               aggregated_player_stats_by_tournament.id
             ) == aggregated_player_stats_by_tournament
    end

    test "create_aggregated_player_stats_by_tournament/1 with valid data creates a aggregated_player_stats_by_tournament" do
      valid_attrs = PlayerHelpers.map_player_id_and_tournament_id(@valid_attrs)

      assert {:ok, %AggregatedPlayerStatsByTournament{} = aggregated_player_stats_by_tournament} =
               AggregatedPlayerStatsByTournaments.create_aggregated_player_stats_by_tournament(
                 valid_attrs
               )

      assert aggregated_player_stats_by_tournament.player_id != nil
      assert aggregated_player_stats_by_tournament.stats == %{"some" => "8"}
      assert aggregated_player_stats_by_tournament.tournament_id != nil
    end

    test "create_aggregated_player_stats_by_tournament/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               AggregatedPlayerStatsByTournaments.create_aggregated_player_stats_by_tournament(
                 @invalid_attrs
               )
    end

    test "update_aggregated_player_stats_by_tournament/2 with valid data updates the aggregated_player_stats_by_tournament" do
      aggregated_player_stats_by_tournament = aggregated_player_stats_by_tournament_fixture()

      assert {:ok, %AggregatedPlayerStatsByTournament{} = aggregated_player_stats_by_tournament} =
               AggregatedPlayerStatsByTournaments.update_aggregated_player_stats_by_tournament(
                 aggregated_player_stats_by_tournament,
                 @update_attrs
               )

      assert aggregated_player_stats_by_tournament.player_id ==
               aggregated_player_stats_by_tournament.player_id

      assert aggregated_player_stats_by_tournament.stats == %{"some" => "10"}

      assert aggregated_player_stats_by_tournament.tournament_id ==
               aggregated_player_stats_by_tournament.tournament_id
    end

    test "update_aggregated_player_stats_by_tournament/2 with invalid data returns error changeset" do
      aggregated_player_stats_by_tournament = aggregated_player_stats_by_tournament_fixture()

      assert {:error, %Ecto.Changeset{}} =
               AggregatedPlayerStatsByTournaments.update_aggregated_player_stats_by_tournament(
                 aggregated_player_stats_by_tournament,
                 @invalid_attrs
               )

      assert aggregated_player_stats_by_tournament ==
               AggregatedPlayerStatsByTournaments.get_aggregated_player_stats_by_tournament!(
                 aggregated_player_stats_by_tournament.id
               )
    end

    test "delete_aggregated_player_stats_by_tournament/1 deletes the aggregated_player_stats_by_tournament" do
      aggregated_player_stats_by_tournament = aggregated_player_stats_by_tournament_fixture()

      assert {:ok, %AggregatedPlayerStatsByTournament{}} =
               AggregatedPlayerStatsByTournaments.delete_aggregated_player_stats_by_tournament(
                 aggregated_player_stats_by_tournament
               )

      assert_raise Ecto.NoResultsError, fn ->
        AggregatedPlayerStatsByTournaments.get_aggregated_player_stats_by_tournament!(
          aggregated_player_stats_by_tournament.id
        )
      end
    end

    test "change_aggregated_player_stats_by_tournament/1 returns a aggregated_player_stats_by_tournament changeset" do
      aggregated_player_stats_by_tournament = aggregated_player_stats_by_tournament_fixture()

      assert %Ecto.Changeset{} =
               AggregatedPlayerStatsByTournaments.change_aggregated_player_stats_by_tournament(
                 aggregated_player_stats_by_tournament
               )
    end

    test "generate_aggregated_player_stats_for_tournament/1 inserts aggregated player stats" do
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

      AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      [aggregated_player_stats_by_tournament] =
        AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()

      assert aggregated_player_stats_by_tournament.player_id == first_valid_attrs.player_id

      {:ok, first_stat_value} =
        Map.fetch(aggregated_player_stats_by_tournament.stats, first_player_stat.id)

      assert first_stat_value == 10.0

      {:ok, second_stat_value} =
        Map.fetch(aggregated_player_stats_by_tournament.stats, second_player_stat.id)

      assert second_stat_value == 5

      assert aggregated_player_stats_by_tournament.tournament_id ==
               first_valid_attrs.tournament_id
    end

    test "generate_aggregated_player_stats_for_tournament/1 inserts aggregated player stats when player stats has a string" do
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

      AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      [aggregated_player_stats_by_tournament] =
        AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()

      assert aggregated_player_stats_by_tournament.player_id == first_valid_attrs.player_id

      {:ok, first_stat_value} =
        Map.fetch(aggregated_player_stats_by_tournament.stats, first_player_stat.id)

      assert first_stat_value == 4.0

      {:ok, second_stat_value} =
        Map.fetch(aggregated_player_stats_by_tournament.stats, second_player_stat.id)

      assert second_stat_value == 5

      assert aggregated_player_stats_by_tournament.tournament_id ==
               first_valid_attrs.tournament_id
    end

    test "generate_aggregated_player_stats_for_tournament/1 inserts aggregated player stats when player stats is a game calculate" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      # Total Rebounds is 6 for first stats logs
      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            "rebounds_defensive" => "1",
            "rebounds_offensive" => "5"
          }
        })

      # Total Rebounds is 4 for second stats log
      second_valid_attrs =
        %{
          stats: %{"rebounds_defensive" => "2", "rebounds_offensive" => "2"}
        }
        |> Map.merge(%{
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      [aggregated_player_stats_by_tournament] =
        AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()

      assert aggregated_player_stats_by_tournament.player_id == first_valid_attrs.player_id

      {:ok, rebounds} = Map.fetch(aggregated_player_stats_by_tournament.stats, "rebounds")
      assert rebounds == 10.0

      assert aggregated_player_stats_by_tournament.tournament_id ==
               first_valid_attrs.tournament_id
    end

    test "generate_aggregated_player_stats_for_tournament/1 inserts aggregated player stats when player stats is per game" do
      valid_tournament = OrganizationHelpers.map_organization_id(@valid_tournament_attrs)
      assert {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(valid_tournament)

      first_valid_attrs =
        PlayerHelpers.map_player_id(tournament.id, %{
          stats: %{
            "rebounds_offensive" => "6",
            "game_played" => "1"
          }
        })

      second_valid_attrs =
        %{
          stats: %{"rebounds_offensive" => "4", "game_played" => "1"}
        }
        |> Map.merge(%{
          player_id: first_valid_attrs.player_id,
          tournament_id: first_valid_attrs.tournament_id
        })

      assert {:ok, _batch_results} =
               PlayerStatsLogs.create_player_stats_logs([first_valid_attrs, second_valid_attrs])

      AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      [aggregated_player_stats_by_tournament] =
        AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()

      assert aggregated_player_stats_by_tournament.player_id == first_valid_attrs.player_id

      {:ok, rebounds} = Map.fetch(aggregated_player_stats_by_tournament.stats, "rebounds")
      assert rebounds == 10.0

      {:ok, rebounds_per_game} =
        Map.fetch(aggregated_player_stats_by_tournament.stats, "rebounds_per_game")

      assert rebounds_per_game == 5.0

      assert aggregated_player_stats_by_tournament.tournament_id ==
               first_valid_attrs.tournament_id
    end

    test "delete_aggregated_player_stats_for_tournament/1 deletes aggregated player stats log" do
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

      AggregatedPlayerStatsByTournaments.generate_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      assert 1 ==
               AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()
               |> Enum.count()

      AggregatedPlayerStatsByTournaments.delete_aggregated_player_stats_for_tournament(
        first_valid_attrs.tournament_id
      )

      assert 0 ==
               AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()
               |> Enum.count()
    end
  end
end
