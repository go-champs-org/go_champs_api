defmodule GoChampsApiWeb.GameControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Games
  alias GoChampsApi.Games.Game
  alias GoChampsApi.Phases

  @create_attrs %{
    away_placeholder: "away placeholder",
    away_score: 10,
    datetime: "2019-08-25T16:59:27.116Z",
    home_placeholder: "home placeholder",
    home_score: 20,
    location: "some location"
  }
  @update_attrs %{
    away_placeholder: "away placeholder updated",
    away_score: 20,
    datetime: "2019-08-25T16:59:27.116Z",
    home_placeholder: "home placeholder updated",
    home_score: 30,
    is_finished: true,
    location: "another location"
  }

  def fixture(:game) do
    {:ok, game} =
      @create_attrs
      |> PhaseHelpers.map_phase_id()
      |> Games.create_game()

    game
  end

  def fixture(:game_with_different_member) do
    {:ok, game} =
      @create_attrs
      |> PhaseHelpers.map_phase_id_with_other_member()
      |> Games.create_game()

    game
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all games", %{conn: conn} do
      conn = get(conn, Routes.v1_game_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end

    test "lists all games matching where", %{conn: conn} do
      first_game = fixture(:game)

      first_phase = Phases.get_phase!(first_game.phase_id)

      {:ok, second_phase} =
        Phases.create_phase(%{
          title: "another phase",
          type: "stadings",
          tournament_id: first_phase.tournament_id
        })

      {:ok, second_game} =
        @create_attrs
        |> Map.merge(%{phase_id: second_phase.id})
        |> Games.create_game()

      where = %{"phase_id" => second_game.phase_id}

      conn = get(conn, Routes.v1_game_path(conn, :index, where: where))
      [game_result] = json_response(conn, 200)["data"]
      assert game_result["id"] == second_game.id
    end
  end

  describe "create game" do
    @tag :authenticated
    test "renders game when data is valid", %{conn: conn} do
      create_attrs = PhaseHelpers.map_phase_id(@create_attrs)
      conn = post(conn, Routes.v1_game_path(conn, :create), game: create_attrs)
      assert %{"id" => id, "phase_id" => phase_id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_game_path(conn, :show, id))

      assert %{
               "away_placeholder" => "away placeholder",
               "away_score" => 10,
               "away_team" => nil,
               "datetime" => "2019-08-25T16:59:27Z",
               "phase_id" => phase_id,
               "home_placeholder" => "home placeholder",
               "home_score" => 20,
               "home_team" => nil,
               "id" => id,
               "is_finished" => false,
               "location" => "some location"
             } = json_response(conn, 200)["data"]
    end
  end

  describe "create game with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = PhaseHelpers.map_phase_id_with_other_member(@create_attrs)

      conn = post(conn, Routes.v1_game_path(conn, :create), game: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update game" do
    setup [:create_game]

    @tag :authenticated
    test "renders game when data is valid", %{conn: conn, game: %Game{id: id} = game} do
      conn = put(conn, Routes.v1_game_path(conn, :update, game), game: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_game_path(conn, :show, id))

      assert %{
               "away_placeholder" => "away placeholder updated",
               "away_score" => 20,
               "away_team" => nil,
               "datetime" => "2019-08-25T16:59:27Z",
               "home_placeholder" => "home placeholder updated",
               "home_score" => 30,
               "home_team" => nil,
               "id" => id,
               "is_finished" => true,
               "location" => "another location"
             } = json_response(conn, 200)["data"]
    end
  end

  describe "update game with different member" do
    setup [:create_game_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, game: game} do
      conn =
        put(
          conn,
          Routes.v1_game_path(
            conn,
            :update,
            game
          ),
          game: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete game" do
    setup [:create_game]

    @tag :authenticated
    test "deletes chosen game", %{conn: conn, game: game} do
      conn = delete(conn, Routes.v1_game_path(conn, :delete, game))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_game_path(conn, :show, game))
      end
    end
  end

  describe "delete game with different member" do
    setup [:create_game_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, game: game} do
      conn =
        delete(
          conn,
          Routes.v1_game_path(
            conn,
            :delete,
            game
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_game(_) do
    game = fixture(:game)
    {:ok, game: game}
  end

  defp create_game_with_different_member(_) do
    game = fixture(:game_with_different_member)
    {:ok, game: game}
  end
end
