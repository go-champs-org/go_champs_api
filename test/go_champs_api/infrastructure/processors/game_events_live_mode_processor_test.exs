defmodule GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessorTest do
  use ExUnit.Case
  alias GoChampsApi.Infrastructure.Processors.GameEventsLiveModeProcessor

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

  describe "process/1 with valid message" do
    test "process the event calling the correct function" do
      assert :ok == GameEventsLiveModeProcessor.process(@valid_message)
    end
  end

  describe "process/1 with invalid message" do
    test "returns error" do
      assert :error == GameEventsLiveModeProcessor.process(@invalid_message)
    end
  end
end
