defmodule GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessorTest do
  use GoChampsApi.DataCase
  import ExUnit.CaptureLog

  alias GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Phases
  alias GoChampsApi.PlayerStatsLogs
  alias GoChampsApi.Games
  alias GoChampsApi.Teams
  alias GoChampsApi.Players

  @valid_start_message %{
    "metadata" => %{
      "sender" => "go-champs-scoreboard",
      "env" => "test"
    },
    "body" => %{
      "event" => %{
        "key" => "start-game-live-mode",
        "timestamp" => "2019-08-25T16:59:27.116Z"
      }
    }
  }
  @valid_end_message %{
    "metadata" => %{
      "sender" => "go-champs-scoreboard",
      "env" => "test"
    },
    "body" => %{
      "event" => %{
        "key" => "end-game-live-mode",
        "timestamp" => "2019-08-25T16:59:27.116Z"
      },
      "game_state" => %{
        "id" => "some-game-id",
        "away_team" => %{
          "name" => "away team",
          "players" => [
            %{
              "id" => "player-1-id",
              "name" => "player 1",
              "number" => 1,
              "stats_values" => %{
                "points" => 1,
                "rebounds" => 2,
                "assists" => 3
              }
            },
            %{
              "id" => "player-2-id",
              "name" => "player 2",
              "number" => 2,
              "stats_values" => %{
                "points" => 4,
                "rebounds" => 5,
                "assists" => 6
              }
            }
          ]
        },
        "home_team" => %{
          "name" => "home team",
          "players" => [
            %{
              "id" => "player-3-id",
              "name" => "player 3",
              "number" => 11,
              "stats_values" => %{
                "points" => 7,
                "rebounds" => 8,
                "assists" => 9
              }
            },
            %{
              "id" => "player-4-id",
              "name" => "player 4",
              "number" => 22,
              "stats_values" => %{
                "points" => 10,
                "rebounds" => 11,
                "assists" => 12
              }
            }
          ]
        }
      }
    }
  }
  @game_attrs %{
    away_score: 10,
    datetime: "2019-08-25T16:59:27.116Z",
    home_score: 20,
    location: "some location"
  }
  @invalid_message %{}

  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(@game_attrs)
      |> PhaseHelpers.map_phase_id()
      |> Games.create_game()

    phase = Phases.get_phase!(game.phase_id)
    tournament_id = phase.tournament_id

    {:ok, home_team} =
      %{"name" => "home team", "tournament_id" => tournament_id} |> Teams.create_team()

    {:ok, _player_1} =
      %{"name" => "player 1", "team_id" => home_team.id, "tournament_id" => tournament_id}
      |> Players.create_player()

    {:ok, _player_2} =
      %{"name" => "player 2", "team_id" => home_team.id, "tournament_id" => tournament_id}
      |> Players.create_player()

    {:ok, away_team} =
      %{"name" => "away team", "tournament_id" => tournament_id} |> Teams.create_team()

    {:ok, _player_3} =
      %{"name" => "player 3", "team_id" => away_team.id, "tournament_id" => tournament_id}
      |> Players.create_player()

    {:ok, _player_4} =
      %{"name" => "player 4", "team_id" => away_team.id, "tournament_id" => tournament_id}
      |> Players.create_player()

    {:ok, updated_game} =
      Games.update_game(game, %{"home_team_id" => home_team.id, "away_team_id" => away_team.id})

    updated_game
  end

  def set_game_id_in_event(event, game_id) do
    put_in(event["body"]["event"]["game_id"], game_id)
  end

  describe "process/1 with valid start message" do
    test "process the event calling the correct function" do
      game = game_fixture()

      message = set_game_id_in_event(@valid_start_message, game.id)

      assert :ok == GameEventsLiveModeProcessor.process(message)

      updated_game = Games.get_game!(game.id)

      assert updated_game.live_state == :in_progress
      assert updated_game.live_started_at != nil
    end
  end

  describe "process/1 with a valid end message" do
    test "updates game live state" do
      game = game_fixture()

      message = set_game_id_in_event(@valid_end_message, game.id)
      message = put_in(message["body"]["event"]["key"], "end-game-live-mode")

      [player_1, player_2, player_3, player_4] = Players.list_players()

      message =
        put_in(
          message["body"]["game_state"]["away_team"]["players"],
          put_in_players(message["body"]["game_state"]["away_team"]["players"], [
            player_1,
            player_2
          ])
        )

      message =
        put_in(
          message["body"]["game_state"]["home_team"]["players"],
          put_in_players(message["body"]["game_state"]["home_team"]["players"], [
            player_3,
            player_4
          ])
        )

      assert :ok == GameEventsLiveModeProcessor.process(message)

      updated_game = Games.get_game!(game.id)

      assert updated_game.live_state == :ended
      assert updated_game.live_ended_at != nil
    end

    test "creates player stats logs" do
      game = game_fixture()

      message = set_game_id_in_event(@valid_end_message, game.id)
      message = put_in(message["body"]["event"]["key"], "end-game-live-mode")

      [player_1, player_2, player_3, player_4] = Players.list_players()

      message =
        put_in(
          message["body"]["game_state"]["away_team"]["players"],
          put_in_players(message["body"]["game_state"]["away_team"]["players"], [
            player_1,
            player_2
          ])
        )

      message =
        put_in(
          message["body"]["game_state"]["home_team"]["players"],
          put_in_players(message["body"]["game_state"]["home_team"]["players"], [
            player_3,
            player_4
          ])
        )

      assert :ok == GameEventsLiveModeProcessor.process(message)

      phase = Phases.get_phase!(game.phase_id)

      message["body"]["game_state"]["away_team"]["players"]
      |> Enum.each(fn player ->
        [player_stats_log] =
          PlayerStatsLogs.list_player_stats_log(game_id: game.id, player_id: player["id"])

        assert player_stats_log.game_id == game.id
        assert player_stats_log.phase_id == game.phase_id
        assert player_stats_log.player_id == player["id"]
        assert player_stats_log.team_id == game.away_team_id
        assert player_stats_log.tournament_id == phase.tournament_id
        assert player_stats_log.stats["assists"] == to_string(player["stats_values"]["assists"])
        assert player_stats_log.stats["points"] == to_string(player["stats_values"]["points"])
        assert player_stats_log.stats["rebounds"] == to_string(player["stats_values"]["rebounds"])
      end)

      message["body"]["game_state"]["home_team"]["players"]
      |> Enum.each(fn player ->
        [player_stats_log] =
          PlayerStatsLogs.list_player_stats_log(game_id: game.id, player_id: player["id"])

        assert player_stats_log.game_id == game.id
        assert player_stats_log.phase_id == game.phase_id
        assert player_stats_log.player_id == player["id"]
        assert player_stats_log.team_id == game.home_team_id
        assert player_stats_log.tournament_id == phase.tournament_id
        assert player_stats_log.stats["assists"] == to_string(player["stats_values"]["assists"])
        assert player_stats_log.stats["points"] == to_string(player["stats_values"]["points"])
        assert player_stats_log.stats["rebounds"] == to_string(player["stats_values"]["rebounds"])
      end)
    end

    test "creates player when player when player id does not exist" do
      game = game_fixture()

      message = set_game_id_in_event(@valid_end_message, game.id)
      message = put_in(message["body"]["event"]["key"], "end-game-live-mode")

      assert :ok == GameEventsLiveModeProcessor.process(message)

      phase = Phases.get_phase!(game.phase_id)

      message["body"]["game_state"]["away_team"]["players"]
      |> Enum.each(fn player ->
        db_player = find_player_by_game_id_and_name(game.id, player["name"])

        [player_stats_log] =
          PlayerStatsLogs.list_player_stats_log(game_id: game.id, player_id: db_player.id)

        assert player_stats_log.game_id == game.id
        assert player_stats_log.phase_id == game.phase_id
        assert player_stats_log.team_id == game.away_team_id
        assert player_stats_log.tournament_id == phase.tournament_id
        assert player_stats_log.stats["assists"] == to_string(player["stats_values"]["assists"])
        assert player_stats_log.stats["points"] == to_string(player["stats_values"]["points"])
        assert player_stats_log.stats["rebounds"] == to_string(player["stats_values"]["rebounds"])
      end)

      message["body"]["game_state"]["home_team"]["players"]
      |> Enum.each(fn player ->
        db_player = find_player_by_game_id_and_name(game.id, player["name"])

        [player_stats_log] =
          PlayerStatsLogs.list_player_stats_log(game_id: game.id, player_id: db_player.id)

        assert player_stats_log.game_id == game.id
        assert player_stats_log.phase_id == game.phase_id
        assert player_stats_log.team_id == game.home_team_id
        assert player_stats_log.tournament_id == phase.tournament_id
        assert player_stats_log.stats["assists"] == to_string(player["stats_values"]["assists"])
        assert player_stats_log.stats["points"] == to_string(player["stats_values"]["points"])
        assert player_stats_log.stats["rebounds"] == to_string(player["stats_values"]["rebounds"])
      end)
    end
  end

  describe "process/1 with not found game" do
    log =
      capture_log(fn ->
        assert :error == GameEventsLiveModeProcessor.process(@valid_start_message)
      end)

    assert log =~ "Error processing event"
  end

  describe "process/1 with invalid message" do
    test "returns error" do
      assert :error == GameEventsLiveModeProcessor.process(@invalid_message)
    end
  end

  defp put_in_players(player_states, players) do
    Enum.map(player_states, fn player_state ->
      player = Enum.find(players, fn player -> player.name == player_state["name"] end)

      put_in(player_state["id"], player.id)
    end)
  end

  defp find_player_by_game_id_and_name(game_id, name) do
    player_logs = PlayerStatsLogs.list_player_stats_log(game_id: game_id)

    player_log =
      Enum.find(player_logs, fn player_log ->
        player = Players.get_player!(player_log.player_id)

        player.name == name
      end)

    Players.get_player!(player_log.player_id)
  end
end
