defmodule GoChampsApiWeb.RegistrationResponseControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Registrations
  alias GoChampsApi.Registrations.RegistrationResponse

  alias GoChampsApi.Helpers.RegistrationHelpers

  @create_attrs %{
    response: %{"some" => "data"}
  }
  @update_attrs %{
    response: %{"some" => "other data"},
    status: "approved"
  }
  @invalid_attrs %{registration_id: nil, response: nil}

  def fixture(:registration_response) do
    create_attrs =
      @create_attrs
      |> RegistrationHelpers.map_registration_invite_id_in_attrs()

    {:ok, registration_response} = Registrations.create_registration_response(create_attrs)
    registration_response
  end

  def fixture(:registration_response_with_different_member) do
    registration_invite_with_different_member =
      %{}
      |> RegistrationHelpers.map_registration_id_with_other_member()
      |> RegistrationHelpers.create_registration_invite()

    create_attrs =
      @create_attrs
      |> Map.merge(%{registration_invite_id: registration_invite_with_different_member.id})

    {:ok, registration_response} = Registrations.create_registration_response(create_attrs)
    registration_response
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all registration_responses", %{conn: conn} do
      conn = get(conn, Routes.v1_registration_response_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create registration_response" do
    test "renders registration_response when data is valid", %{conn: conn} do
      create_attrs =
        @create_attrs
        |> RegistrationHelpers.map_registration_invite_id_in_attrs()

      conn =
        post(conn, Routes.v1_registration_response_path(conn, :create),
          registration_response: create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_registration_response_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "response" => %{"some" => "data"},
               "status" => "pending"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.v1_registration_response_path(conn, :create),
          registration_response: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update registration_response" do
    setup [:create_registration_response]

    @tag :authenticated
    test "renders registration_response when data is valid", %{
      conn: conn,
      registration_response: %RegistrationResponse{id: id} = registration_response
    } do
      conn =
        put(conn, Routes.v1_registration_response_path(conn, :update, registration_response),
          registration_response: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_registration_response_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "response" => %{"some" => "other data"},
               "status" => "approved"
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{
      conn: conn,
      registration_response: registration_response
    } do
      conn =
        put(conn, Routes.v1_registration_response_path(conn, :update, registration_response),
          registration_response: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update registration_response with different member" do
    setup [:create_registration_response_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      registration_response: registration_response
    } do
      update_attrs =
        @update_attrs
        |> Map.merge(%{registration_invite_id: registration_response.registration_invite_id})

      conn =
        put(
          conn,
          Routes.v1_registration_response_path(
            conn,
            :update,
            registration_response
          ),
          registration_response: update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete registration_response" do
    setup [:create_registration_response]

    @tag :authenticated
    test "deletes chosen registration_response", %{
      conn: conn,
      registration_response: registration_response
    } do
      conn =
        delete(conn, Routes.v1_registration_response_path(conn, :delete, registration_response))

      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_registration_response_path(conn, :show, registration_response))
      end
    end
  end

  describe "delete registration_response with different member" do
    setup [:create_registration_response_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      registration_response: registration_response
    } do
      conn =
        delete(
          conn,
          Routes.v1_registration_response_path(
            conn,
            :delete,
            registration_response
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_registration_response(_) do
    registration_response = fixture(:registration_response)
    %{registration_response: registration_response}
  end

  defp create_registration_response_with_different_member(_) do
    registration_response = fixture(:registration_response_with_different_member)
    {:ok, registration_response: registration_response}
  end
end
