defmodule GoChampsApiWeb.SportsControllerTest do
  use GoChampsApiWeb.ConnCase
  alias GoChampsApi.Sports.Basketball5x5.Basketball5x5

  describe "index" do
    test "lists all sports", %{conn: conn} do
      expected_player_statistics =
        Basketball5x5.sport().player_statistics
        |> Enum.map(
          &%{
            "slug" => &1.slug,
            "name" => &1.name
          }
        )

      conn = get(conn, Routes.v1_sports_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{
                 "name" => "Basketball 5x5",
                 "slug" => "basketball_5x5",
                 "player_statistics" => expected_player_statistics
               }
             ]
    end
  end

  describe "show" do
    test "returns a sport with associated player_stats", %{conn: conn} do
      conn = get(conn, Routes.v1_sports_path(conn, :show, "basketball_5x5"))

      expected_player_statistics =
        Basketball5x5.sport().player_statistics
        |> Enum.map(
          &%{
            "slug" => &1.slug,
            "name" => &1.name
          }
        )

      assert json_response(conn, 200)["data"] == %{
               "name" => "Basketball 5x5",
               "slug" => "basketball_5x5",
               "player_statistics" => expected_player_statistics
             }
    end
  end
end
