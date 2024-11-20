defmodule GoChampsApi.SportsTest do
  use ExUnit.Case
  alias GoChampsApi.Sports

  describe "list_sports/0" do
    test "returns all sports" do
      sports = [
        %Sports.Sport{
          slug: "basketball-5x5",
          name: "Basketball 5x5"
        }
      ]

      assert Sports.list_sports() == sports
    end
  end
end
