defmodule GoChampsApi.PlayersTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Players
  alias GoChampsApi.Tournaments
  alias GoChampsApi.AggregatedPlayerStatsByTournaments
  alias GoChampsApi.PlayerStatsLogs

  describe "players" do
    alias GoChampsApi.Players.Player

    @valid_attrs %{
      facebook: "some facebook",
      instagram: "some instagram",
      name: "some name",
      twitter: "some twitter",
      username: "some username",
      shirt_number: "10",
      shirt_name: "some shirt name",
      photo_url: "some-photo-url"
    }
    @update_attrs %{
      facebook: "some updated facebook",
      instagram: "some updated instagram",
      name: "some updated name",
      twitter: "some updated twitter",
      username: "some updated username",
      shirt_number: "20",
      shirt_name: "some updated shirt name",
      state: "not_available",
      photo_url: "some-updated-photo-url"
    }
    @invalid_attrs %{facebook: nil, instagram: nil, name: nil, twitter: nil, username: nil}

    def player_fixture(attrs \\ %{}) do
      {:ok, player} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TournamentHelpers.map_tournament_id()
        |> Players.create_player()

      player
    end

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Players.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Players.get_player!(player.id) == player
    end

    test "get_player_organization!/1 returns the organization with a give player id" do
      player = player_fixture()

      organization = Players.get_player_organization!(player.id)

      tournament = Tournaments.get_tournament!(player.tournament_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "get_player_or_create/1 returns the player with given id" do
      player = player_fixture()
      assert Players.get_player_or_create(%Player{id: player.id}) == {:ok, player}
    end

    test "get_player_or_create/1 create player and returns the player" do
      player =
        %{
          id: "some random id",
          name: "New Player"
        }
        |> TournamentHelpers.map_tournament_id()

      {:ok, result_player} = Players.get_player_or_create(player)

      assert result_player.name == "New Player"
      assert result_player.tournament_id == player.tournament_id
    end

    test "create_player/1 with valid data creates a player" do
      valid_attrs = TournamentHelpers.map_tournament_id(@valid_attrs)
      assert {:ok, %Player{} = player} = Players.create_player(valid_attrs)
      assert player.facebook == "some facebook"
      assert player.instagram == "some instagram"
      assert player.name == "some name"
      assert player.twitter == "some twitter"
      assert player.username == "some username"
      assert player.shirt_number == "10"
      assert player.shirt_name == "some shirt name"
      assert player.state == "available"
      assert player.photo_url == "some-photo-url"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Players.create_player(@invalid_attrs)
    end

    test "create_player/1 with random state returns error changeset" do
      valid_attrs = TournamentHelpers.map_tournament_id(@valid_attrs)
      invalid_attrs = Map.put(valid_attrs, :state, "random_state")
      assert {:error, %Ecto.Changeset{}} = Players.create_player(invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      assert {:ok, %Player{} = player} = Players.update_player(player, @update_attrs)
      assert player.facebook == "some updated facebook"
      assert player.instagram == "some updated instagram"
      assert player.name == "some updated name"
      assert player.twitter == "some updated twitter"
      assert player.username == "some updated username"
      assert player.shirt_number == "20"
      assert player.shirt_name == "some updated shirt name"
      assert player.state == "not_available"
      assert player.photo_url == "some-updated-photo-url"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Players.update_player(player, @invalid_attrs)
      assert player == Players.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Players.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Players.get_player!(player.id) end
    end

    test "delete_player/1 and associated player_stats_log" do
      player = player_fixture()

      {:ok, _player_stats_log} =
        PlayerStatsLogs.create_player_stats_log(%{
          player_id: player.id,
          tournament_id: player.tournament_id,
          stats: %{
            "kills" => 10,
            "deaths" => 5
          }
        })

      assert {:ok, %Player{}} = Players.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Players.get_player!(player.id) end
      assert [] = PlayerStatsLogs.list_player_stats_log(player_id: player.id)
    end

    test "delete_player/1 and associated aggregated_player_stats_log" do
      player = player_fixture()

      {:ok, _aggregated_player_stats_log} =
        AggregatedPlayerStatsByTournaments.create_aggregated_player_stats_by_tournament(%{
          player_id: player.id,
          tournament_id: player.tournament_id,
          stats: %{
            "kills" => 10,
            "deaths" => 5
          }
        })

      assert {:ok, %Player{}} = Players.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Players.get_player!(player.id) end

      assert [] =
               AggregatedPlayerStatsByTournaments.list_aggregated_player_stats_by_tournament(
                 player_id: player.id
               )
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Players.change_player(player)
    end
  end
end
