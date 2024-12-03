defmodule GoChampsApiWeb.PlayerControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Players
  alias GoChampsApi.Players.Player

  @create_attrs %{
    facebook: "some facebook",
    instagram: "some instagram",
    name: "some name",
    twitter: "some twitter",
    username: "some username"
  }
  @update_attrs %{
    facebook: "some updated facebook",
    instagram: "some updated instagram",
    name: "some updated name",
    twitter: "some updated twitter",
    username: "some updated username"
  }
  @invalid_attrs %{facebook: nil, instagram: nil, name: nil, twitter: nil, username: nil}

  def fixture(:player) do
    {:ok, player} =
      @create_attrs
      |> TournamentHelpers.map_tournament_id()
      |> Players.create_player()

    player
  end

  def fixture(:player_with_different_member) do
    attrs = TournamentHelpers.map_tournament_id_with_other_member(@create_attrs)
    {:ok, player} = Players.create_player(attrs)
    player
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create player" do
    @tag :authenticated
    test "renders player when data is valid", %{conn: conn} do
      create_attrs = TournamentHelpers.map_tournament_id(@create_attrs)
      conn = post(conn, Routes.v1_player_path(conn, :create), player: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_player_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "facebook" => "some facebook",
               "instagram" => "some instagram",
               "name" => "some name",
               "twitter" => "some twitter",
               "username" => "some username"
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = TournamentHelpers.map_tournament_id(@invalid_attrs)
      conn = post(conn, Routes.v1_player_path(conn, :create), player: invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create player with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = TournamentHelpers.map_tournament_id_with_other_member(@create_attrs)

      conn = post(conn, Routes.v1_player_path(conn, :create), player: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update player" do
    setup [:create_player]

    @tag :authenticated
    test "renders player when data is valid", %{conn: conn, player: %Player{id: id} = player} do
      conn = put(conn, Routes.v1_player_path(conn, :update, player), player: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_player_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "facebook" => "some updated facebook",
               "instagram" => "some updated instagram",
               "name" => "some updated name",
               "twitter" => "some updated twitter",
               "username" => "some updated username"
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, player: player} do
      conn = put(conn, Routes.v1_player_path(conn, :update, player), player: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update player with different member" do
    setup [:create_player_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, player: player} do
      conn =
        put(
          conn,
          Routes.v1_player_path(
            conn,
            :update,
            player
          ),
          player: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete player" do
    setup [:create_player]

    @tag :authenticated
    test "deletes chosen player", %{conn: conn, player: player} do
      conn = delete(conn, Routes.v1_player_path(conn, :delete, player))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_player_path(conn, :show, player))
      end
    end
  end

  describe "delete player with different member" do
    setup [:create_player_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, player: player} do
      conn =
        delete(
          conn,
          Routes.v1_player_path(
            conn,
            :delete,
            player
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_player(_) do
    player = fixture(:player)
    {:ok, player: player}
  end

  defp create_player_with_different_member(_) do
    player = fixture(:player_with_different_member)
    {:ok, player: player}
  end
end
