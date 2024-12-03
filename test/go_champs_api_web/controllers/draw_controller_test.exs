defmodule GoChampsApiWeb.DrawControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Draws
  alias GoChampsApi.Draws.Draw
  alias GoChampsApi.Helpers.PhaseHelpers

  @create_attrs %{
    title: "some title",
    matches: [
      %{
        first_team_placeholder: "some-first-team-placeholder",
        info: "some info",
        name: "some name",
        second_team_placeholder: "some-second-team-placeholder"
      }
    ]
  }
  @update_attrs %{
    title: "some updated title",
    matches: [
      %{
        first_team_placeholder: "some-updated-first-team-placeholder",
        info: "some updated info",
        name: "some updated name",
        second_team_placeholder: "some-updated-second-team-placeholder"
      }
    ]
  }
  @invalid_attrs %{title: nil, matches: nil}

  def fixture(:draw) do
    draw_attrs = PhaseHelpers.map_phase_id(@create_attrs)
    {:ok, draw} = Draws.create_draw(draw_attrs)
    draw
  end

  def fixture(:draw_with_different_member) do
    {:ok, draw} =
      @create_attrs
      |> PhaseHelpers.map_phase_id_with_other_member()
      |> Draws.create_draw()

    draw
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create draw" do
    @tag :authenticated
    test "renders draw when data is valid", %{conn: conn} do
      create_attrs = PhaseHelpers.map_phase_id(@create_attrs)
      conn = post(conn, Routes.v1_draw_path(conn, :create), draw: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_draw_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "title" => "some title",
               "matches" => [
                 %{
                   "first_team_placeholder" => result_first_team_placeholder,
                   "info" => result_info,
                   "name" => result_name,
                   "second_team_placeholder" => result_second_team_placeholder
                 }
               ]
             } = json_response(conn, 200)["data"]

      assert result_first_team_placeholder == "some-first-team-placeholder"
      assert result_info == "some info"
      assert result_name == "some name"
      assert result_second_team_placeholder == "some-second-team-placeholder"
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs = PhaseHelpers.map_phase_id(@invalid_attrs)
      conn = post(conn, Routes.v1_draw_path(conn, :create), draw: invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create draw with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = PhaseHelpers.map_phase_id_with_other_member(@create_attrs)

      conn = post(conn, Routes.v1_draw_path(conn, :create), draw: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update draw" do
    setup [:create_draw]

    @tag :authenticated
    test "renders draw when data is valid", %{conn: conn, draw: %Draw{id: id} = draw} do
      conn = put(conn, Routes.v1_draw_path(conn, :update, draw), draw: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_draw_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "title" => "some updated title",
               "matches" => [
                 %{
                   "first_team_placeholder" => result_first_team_placeholder,
                   "info" => result_info,
                   "name" => result_name,
                   "second_team_placeholder" => result_second_team_placeholder
                 }
               ]
             } = json_response(conn, 200)["data"]

      assert result_first_team_placeholder == "some-updated-first-team-placeholder"
      assert result_info == "some updated info"
      assert result_name == "some updated name"
      assert result_second_team_placeholder == "some-updated-second-team-placeholder"
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, draw: draw} do
      conn = put(conn, Routes.v1_draw_path(conn, :update, draw), draw: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update draw with different member" do
    setup [:create_draw_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, draw: draw} do
      conn =
        put(
          conn,
          Routes.v1_draw_path(
            conn,
            :update,
            draw
          ),
          draw: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "batch update draw" do
    setup %{conn: conn} do
      first_draw = fixture(:draw)
      attrs = Map.merge(@create_attrs, %{phase_id: first_draw.phase_id})
      {:ok, second_draw} = Draws.create_draw(attrs)
      {:ok, conn: conn, draws: [first_draw, second_draw]}
    end

    @tag :authenticated
    test "renders draws when data is valid", %{
      conn: conn,
      draws: [first_draw, second_draw]
    } do
      first_draw_update = Map.merge(%{id: first_draw.id}, %{title: "first title updated"})

      second_draw_update = Map.merge(%{id: second_draw.id}, %{title: "second title updated"})

      draws = [first_draw_update, second_draw_update]

      conn =
        patch(
          conn,
          Routes.v1_draw_path(
            conn,
            :batch_update
          ),
          draws: draws
        )

      first_draw_id = first_draw.id
      second_draw_id = second_draw.id

      %{
        ^first_draw_id => first_draw_result,
        ^second_draw_id => second_draw_result
      } = json_response(conn, 200)["data"]

      assert first_draw_result["id"] == first_draw.id
      assert first_draw_result["title"] == "first title updated"
      assert second_draw_result["id"] == second_draw.id
      assert second_draw_result["title"] == "second title updated"
    end
  end

  describe "batch update draw with different member" do
    setup [:create_draw_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, draw: draw} do
      draw_update = Map.merge(%{id: draw.id}, %{title: "title updated"})

      conn =
        patch(
          conn,
          Routes.v1_draw_path(
            conn,
            :batch_update
          ),
          draws: [draw_update]
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete draw" do
    setup [:create_draw]

    @tag :authenticated
    test "deletes chosen draw", %{conn: conn, draw: draw} do
      conn = delete(conn, Routes.v1_draw_path(conn, :delete, draw))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_draw_path(conn, :show, draw))
      end
    end
  end

  describe "delete draw with different member" do
    setup [:create_draw_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, draw: draw} do
      conn =
        delete(
          conn,
          Routes.v1_draw_path(
            conn,
            :delete,
            draw
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_draw(_) do
    draw = fixture(:draw)
    {:ok, draw: draw}
  end

  defp create_draw_with_different_member(_) do
    draw = fixture(:draw_with_different_member)
    {:ok, draw: draw}
  end
end
