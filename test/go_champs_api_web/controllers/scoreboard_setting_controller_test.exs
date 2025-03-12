defmodule GoChampsApiWeb.ScoreboardSettingControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.ScoreboardSettings
  alias GoChampsApi.ScoreboardSettings.ScoreboardSetting

  alias GoChampsApi.Helpers.TournamentHelpers

  @create_attrs %{
    view: "basketball-basic"
  }
  @update_attrs %{
    view: "basketball-advanced"
  }
  @invalid_attrs %{view: nil}

  def fixture(:scoreboard_setting) do
    {:ok, scoreboard_setting} =
      @create_attrs
      |> TournamentHelpers.map_tournament_id()
      |> ScoreboardSettings.create_scoreboard_setting()

    scoreboard_setting
  end

  def fixture(:scoreboard_setting_with_different_member) do
    {:ok, scoreboard_setting} =
      @create_attrs
      |> TournamentHelpers.map_tournament_id_with_other_member()
      |> ScoreboardSettings.create_scoreboard_setting()

    scoreboard_setting
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all scoreboard_settings", %{conn: conn} do
      conn = get(conn, Routes.v1_scoreboard_setting_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create scoreboard_setting" do
    @tag :authenticated
    test "renders scoreboard_setting when data is valid", %{conn: conn} do
      create_attrs =
        @create_attrs
        |> TournamentHelpers.map_tournament_id()

      conn =
        post(conn, Routes.v1_scoreboard_setting_path(conn, :create),
          scoreboard_setting: create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_scoreboard_setting_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "view" => "basketball-basic"
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      attrs = TournamentHelpers.map_tournament_id(@invalid_attrs)

      conn =
        post(conn, Routes.v1_scoreboard_setting_path(conn, :create), scoreboard_setting: attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create scoreboard_setting with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = TournamentHelpers.map_tournament_id_with_other_member(@create_attrs)

      conn =
        post(conn, Routes.v1_scoreboard_setting_path(conn, :create), scoreboard_setting: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update scoreboard_setting" do
    setup [:create_scoreboard_setting]

    @tag :authenticated
    test "renders scoreboard_setting when data is valid", %{
      conn: conn,
      scoreboard_setting: %ScoreboardSetting{id: id} = scoreboard_setting
    } do
      conn =
        put(conn, Routes.v1_scoreboard_setting_path(conn, :update, scoreboard_setting),
          scoreboard_setting: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_scoreboard_setting_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "view" => "basketball-advanced"
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{
      conn: conn,
      scoreboard_setting: scoreboard_setting
    } do
      conn =
        put(conn, Routes.v1_scoreboard_setting_path(conn, :update, scoreboard_setting),
          scoreboard_setting: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update scoreboard_setting with different member" do
    setup [:create_scoreboard_setting_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      scoreboard_setting: scoreboard_setting
    } do
      conn =
        put(
          conn,
          Routes.v1_scoreboard_setting_path(
            conn,
            :update,
            scoreboard_setting
          ),
          scoreboard_setting: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete scoreboard_setting" do
    setup [:create_scoreboard_setting]

    @tag :authenticated
    test "deletes chosen scoreboard_setting", %{
      conn: conn,
      scoreboard_setting: scoreboard_setting
    } do
      conn = delete(conn, Routes.v1_scoreboard_setting_path(conn, :delete, scoreboard_setting))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_scoreboard_setting_path(conn, :show, scoreboard_setting))
      end
    end
  end

  describe "delete scoreboard_setting with different member" do
    setup [:create_scoreboard_setting_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      scoreboard_setting: scoreboard_setting
    } do
      conn =
        delete(
          conn,
          Routes.v1_scoreboard_setting_path(
            conn,
            :delete,
            scoreboard_setting
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_scoreboard_setting(_) do
    scoreboard_setting = fixture(:scoreboard_setting)
    %{scoreboard_setting: scoreboard_setting}
  end

  defp create_scoreboard_setting_with_different_member(_) do
    scoreboard_setting = fixture(:scoreboard_setting_with_different_member)
    {:ok, scoreboard_setting: scoreboard_setting}
  end
end
