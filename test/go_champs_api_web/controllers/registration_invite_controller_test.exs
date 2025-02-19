defmodule GoChampsApiWeb.RegistrationInviteControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Registrations
  alias GoChampsApi.Registrations.RegistrationInvite
  alias GoChampsApi.Helpers.RegistrationHelpers

  @create_attrs %{
    invitee_id: Ecto.UUID.autogenerate(),
    invitee_type: "some invitee_type",
    registration_id: "7488a646-e31f-11e4-aace-600308960662"
  }
  @update_attrs %{
    invitee_id: Ecto.UUID.autogenerate(),
    invitee_type: "some updated invitee_type",
    registration_id: "7488a646-e31f-11e4-aace-600308960668"
  }
  @invalid_attrs %{invitee_id: nil, invitee_type: nil, registration_id: nil}

  def fixture(:registration_invite) do
    create_attrs =
      @create_attrs
      |> RegistrationHelpers.map_registration_id_in_attrs()

    {:ok, registration_invite} = Registrations.create_registration_invite(create_attrs)
    registration_invite
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create registration_invite" do
    @tag :authenticated
    test "renders registration_invite when data is valid", %{conn: conn} do
      create_attrs =
        @create_attrs
        |> RegistrationHelpers.map_registration_id_in_attrs()

      conn =
        post(conn, Routes.v1_registration_invite_path(conn, :create),
          registration_invite: create_attrs
        )

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_registration_invite_path(conn, :show, id))

      invitee_id = create_attrs.invitee_id
      registration_id = create_attrs.registration_id

      assert %{
               "id" => ^id,
               "invitee_id" => ^invitee_id,
               "invitee_type" => "some invitee_type",
               "registration_id" => ^registration_id
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.v1_registration_invite_path(conn, :create),
          registration_invite: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update registration_invite" do
    setup [:create_registration_invite]

    @tag :authenticated
    test "renders registration_invite when data is valid", %{
      conn: conn,
      registration_invite: %RegistrationInvite{id: id} = registration_invite
    } do
      update_attrs =
        @update_attrs
        |> Map.merge(%{registration_id: registration_invite.registration_id})

      conn =
        put(conn, Routes.v1_registration_invite_path(conn, :update, registration_invite),
          registration_invite: update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_registration_invite_path(conn, :show, id))

      invitee_id = update_attrs.invitee_id
      registration_id = update_attrs.registration_id

      assert %{
               "id" => ^id,
               "invitee_id" => ^invitee_id,
               "invitee_type" => "some updated invitee_type",
               "registration_id" => ^registration_id
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{
      conn: conn,
      registration_invite: registration_invite
    } do
      invalid_attrs =
        @invalid_attrs
        |> Map.merge(%{registration_id: registration_invite.registration_id})

      conn =
        put(conn, Routes.v1_registration_invite_path(conn, :update, registration_invite),
          registration_invite: invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete registration_invite" do
    setup [:create_registration_invite]

    @tag :authenticated
    test "deletes chosen registration_invite", %{
      conn: conn,
      registration_invite: registration_invite
    } do
      conn = delete(conn, Routes.v1_registration_invite_path(conn, :delete, registration_invite))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_registration_invite_path(conn, :show, registration_invite))
      end
    end
  end

  defp create_registration_invite(_) do
    registration_invite = fixture(:registration_invite)
    %{registration_invite: registration_invite}
  end
end
