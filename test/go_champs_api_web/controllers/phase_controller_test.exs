defmodule GoChampsApiWeb.PhaseControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Phases
  alias GoChampsApi.Phases.Phase

  @create_attrs %{
    title: "some title",
    type: "elimination",
    is_in_progress: true
  }
  @update_attrs %{
    title: "some updated title",
    type: "elimination",
    is_in_progress: false
  }
  @invalid_attrs %{title: nil, type: nil}

  def fixture(:phase) do
    attrs = TournamentHelpers.map_tournament_id(@create_attrs)
    {:ok, phase} = Phases.create_phase(attrs)
    phase
  end

  def fixture(:phase_with_different_member) do
    attrs = TournamentHelpers.map_tournament_id_with_other_member(@create_attrs)
    {:ok, phase} = Phases.create_phase(attrs)
    phase
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create phase" do
    @tag :authenticated
    test "renders phase when data is valid", %{conn: conn} do
      attrs = TournamentHelpers.map_tournament_id(@create_attrs)

      conn = post(conn, Routes.v1_phase_path(conn, :create), phase: attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_phase_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "title" => "some title",
               "type" => "elimination",
               "is_in_progress" => true
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      attrs = TournamentHelpers.map_tournament_id(@invalid_attrs)

      conn = post(conn, Routes.v1_phase_path(conn, :create), phase: attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create phase with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = TournamentHelpers.map_tournament_id_with_other_member(@create_attrs)

      conn = post(conn, Routes.v1_phase_path(conn, :create), phase: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update phase" do
    setup [:create_phase]

    @tag :authenticated
    test "renders phase when data is valid", %{
      conn: conn,
      phase: %Phase{id: id} = phase
    } do
      conn =
        put(
          conn,
          Routes.v1_phase_path(
            conn,
            :update,
            phase
          ),
          phase: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_phase_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "title" => "some updated title",
               "type" => "elimination",
               "is_in_progress" => false
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, phase: phase} do
      conn =
        put(
          conn,
          Routes.v1_phase_path(
            conn,
            :update,
            phase
          ),
          phase: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update phase with different member" do
    setup [:create_phase_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, phase: phase} do
      conn =
        put(
          conn,
          Routes.v1_phase_path(
            conn,
            :update,
            phase
          ),
          phase: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "batch update phase" do
    setup %{conn: conn} do
      first_phase = fixture(:phase)
      attrs = Map.merge(@create_attrs, %{tournament_id: first_phase.tournament_id})
      {:ok, second_phase} = Phases.create_phase(attrs)
      {:ok, conn: conn, phases: [first_phase, second_phase]}
    end

    @tag :authenticated
    test "renders phases when data is valid", %{
      conn: conn,
      phases: [first_phase, second_phase]
    } do
      first_phase_update = Map.merge(%{id: first_phase.id}, %{title: "first title updated"})
      second_phase_update = Map.merge(%{id: second_phase.id}, %{title: "second title updated"})
      phases = [first_phase_update, second_phase_update]

      conn =
        patch(
          conn,
          Routes.v1_phase_path(
            conn,
            :batch_update
          ),
          phases: phases
        )

      first_phase_id = first_phase.id
      second_phase_id = second_phase.id

      %{^first_phase_id => first_phase_result, ^second_phase_id => second_phase_result} =
        json_response(conn, 200)["data"]

      assert first_phase_result["id"] == first_phase.id
      assert first_phase_result["title"] == "first title updated"
      assert second_phase_result["id"] == second_phase.id
      assert second_phase_result["title"] == "second title updated"
    end
  end

  describe "batch update phase with different member" do
    setup [:create_phase_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, phase: phase} do
      phase_update = Map.merge(%{id: phase.id}, %{title: "title updated"})

      conn =
        patch(
          conn,
          Routes.v1_phase_path(
            conn,
            :batch_update
          ),
          phases: [phase_update]
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete phase" do
    setup [:create_phase]

    @tag :authenticated
    test "deletes chosen phase", %{conn: conn, phase: phase} do
      conn =
        delete(
          conn,
          Routes.v1_phase_path(
            conn,
            :delete,
            phase
          )
        )

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(
          conn,
          Routes.v1_phase_path(
            conn,
            :show,
            phase
          )
        )
      end
    end
  end

  describe "delete phase with different member" do
    setup [:create_phase_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn, phase: phase} do
      conn =
        delete(
          conn,
          Routes.v1_phase_path(
            conn,
            :delete,
            phase
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_phase(_) do
    phase = fixture(:phase)
    {:ok, phase: phase}
  end

  defp create_phase_with_different_member(_) do
    phase = fixture(:phase_with_different_member)
    {:ok, phase: phase}
  end
end
