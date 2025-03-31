defmodule GoChampsApi.Infrastructure.Jobs.GenerateAggregatedPlayerStatsTest do
  alias GoChampsApi.Infrastructure.Jobs.GenerateAggregatedPlayerStats
  use GoChampsApi.DataCase

  alias GoChampsApi.AggregatedPlayerStatsByTournaments
  alias GoChampsApi.Helpers.OrganizationHelpers
  alias GoChampsApi.Helpers.PlayerHelpers
  alias GoChampsApi.PlayerStatsLogs
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Tournaments.Tournament

  @valid_tournament_with_stats %{
    name: "some name",
    slug: "some-slug",
    player_stats: [
      %{
        title: "some stat"
      },
      %{
        title: "another stat"
      }
    ]
  }

  test "perform/1" do
    tournament_attrs =
      @valid_tournament_with_stats
      |> OrganizationHelpers.map_organization_id()

    {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(tournament_attrs)

    [first_player_stat, second_player_stat] = tournament.player_stats

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

    {:ok, _} =
      GenerateAggregatedPlayerStats.perform(%Oban.Job{
        args: %{"tournament_id" => tournament.id}
      })

    [aggregated_player_stats_by_tournament] =
      AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()

    assert Map.get(aggregated_player_stats_by_tournament.stats, first_player_stat.id) == 10
    assert Map.get(aggregated_player_stats_by_tournament.stats, second_player_stat.id) == 5
    assert aggregated_player_stats_by_tournament.player_id == first_valid_attrs.player_id
    assert aggregated_player_stats_by_tournament.tournament_id == tournament.id
  end

  test "perform/1 does't not duplicated records for same tournament" do
    tournament_attrs =
      @valid_tournament_with_stats
      |> OrganizationHelpers.map_organization_id()

    {:ok, %Tournament{} = tournament} = Tournaments.create_tournament(tournament_attrs)

    [first_player_stat, second_player_stat] = tournament.player_stats

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

    {:ok, _} =
      GenerateAggregatedPlayerStats.perform(%Oban.Job{
        args: %{"tournament_id" => tournament.id}
      })

    {:ok, _} =
      GenerateAggregatedPlayerStats.perform(%Oban.Job{
        args: %{"tournament_id" => tournament.id}
      })

    [aggregated_player_stats_by_tournament] =
      AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament()

    assert Map.get(aggregated_player_stats_by_tournament.stats, first_player_stat.id) == 10
    assert Map.get(aggregated_player_stats_by_tournament.stats, second_player_stat.id) == 5
    assert aggregated_player_stats_by_tournament.player_id == first_valid_attrs.player_id
    assert aggregated_player_stats_by_tournament.tournament_id == tournament.id
  end
end
