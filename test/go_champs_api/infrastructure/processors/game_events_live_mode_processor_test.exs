defmodule GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessorTest do
  use GoChampsApi.DataCase
  alias GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor
  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Games

  @valid_message %{
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
  @invalid_message %{}
  @game_attrs %{
    away_score: 10,
    datetime: "2019-08-25T16:59:27.116Z",
    home_score: 20,
    location: "some location"
  }

  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(@game_attrs)
      |> PhaseHelpers.map_phase_id()
      |> Games.create_game()

    game
  end

  def set_game_id_in_event(event, game_id) do
    put_in(event["body"]["event"]["game_id"], game_id)
  end

  describe "process/1 with valid message" do
    test "process the event calling the correct function" do
      game = game_fixture()

      message = set_game_id_in_event(@valid_message, game.id)

      assert :ok == GameEventsLiveModeProcessor.process(message)

      updated_game = Games.get_game!(game.id)

      assert updated_game.live_state == :in_progress
      assert updated_game.live_started_at != nil
    end
  end

  describe "process/1 with invalid message" do
    test "returns error" do
      assert :error == GameEventsLiveModeProcessor.process(@invalid_message)
    end
  end
end
