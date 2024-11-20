defmodule GoChampsApiWeb.SportsControllerTest do
  use GoChampsApiWeb.ConnCase

  describe "index" do
    test "lists all sports", %{conn: conn} do
      conn = get(conn, Routes.v1_sports_path(conn, :index))

      assert json_response(conn, 200)["data"] == [
               %{"name" => "Basketball 5x5", "slug" => "basketball-5x5"}
             ]
    end
  end
end
