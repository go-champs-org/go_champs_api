defmodule GoChampsApi.SportsTest do
  use ExUnit.Case
  alias GoChampsApi.Sports
  alias GoChampsApi.Sports.Basketball5x5.Basketball5x5

  describe "list_sports/0" do
    test "returns all sports" do
      sports = [
        Basketball5x5.sport()
      ]

      assert Sports.list_sports() == sports
    end
  end

  describe "get_sport/1" do
    test "returns a sport by slug with associated player_stats" do
      sport = Sports.get_sport("basketball_5x5")

      assert sport.name == "Basketball 5x5"
      assert sport.slug == "basketball_5x5"
    end
  end
end
