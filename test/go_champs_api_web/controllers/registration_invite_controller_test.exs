defmodule GoChampsApiWeb.RegistrationInviteControllerTest do
  alias GoChampsApi.Helpers.TeamHelpers
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

  def fixture(:registration_invite_for_team) do
    team = TeamHelpers.create_team()

    {:ok, registration_invite} =
      %{
        invitee_id: team.id,
        invitee_type: "team",
        tournament_id: team.tournament_id
      }
      |> RegistrationHelpers.map_registration_id_in_attrs()
      |> Registrations.create_registration_invite()

    registration_invite
  end

  def fixture(:registration_invite_with_different_member) do
    create_attrs =
      @create_attrs
      |> RegistrationHelpers.map_registration_id_with_other_member()

    {:ok, registration_invite} = Registrations.create_registration_invite(create_attrs)
    registration_invite
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "get registration_invite" do
    setup [:create_registration_invite_for_team]

    test "renders registration_invite and its associated entities", %{
      conn: conn,
      registration_invite: %RegistrationInvite{id: id} = registration_invite
    } do
      include = "registration,registration.tournament,registration_responses"

      conn =
        get(
          conn,
          Routes.v1_registration_invite_path(conn, :show, id, include: include)
        )

      invitee = Registrations.get_registration_invite_invitee(registration_invite)
      invitee_id = registration_invite.invitee_id
      registration_id = registration_invite.registration_id

      registration = Registrations.get_registration!(registration_invite.registration_id)

      response = json_response(conn, 200)["data"]

      assert response["id"] == id
      assert response["invitee_id"] == invitee_id
      assert response["invitee_type"] == "team"
      assert response["invitee"]["id"] == invitee.id
      assert response["invitee"]["name"] == invitee.name
      assert response["registration_id"] == registration_id
      assert response["registration"]["id"] == registration.id
      assert response["registration"]["title"] == registration.title
      assert response["registration"]["tournament"]["id"] == registration.tournament_id
      assert response["registration"]["tournament"]["name"] == "some tournament"
    end
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
      invalid_attrs =
        @invalid_attrs
        |> RegistrationHelpers.map_registration_id_in_attrs()

      conn =
        post(conn, Routes.v1_registration_invite_path(conn, :create),
          registration_invite: invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create registration_invite with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = RegistrationHelpers.map_registration_id_with_other_member(@create_attrs)

      conn =
        post(conn, Routes.v1_registration_invite_path(conn, :create), registration_invite: attrs)

      assert text_response(conn, 403) == "Forbidden"
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

  describe "update registration_invite with different member" do
    setup [:create_registration_invite_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      registration_invite: registration_invite
    } do
      update_attrs =
        @update_attrs
        |> Map.merge(%{registration_id: registration_invite.registration_id})

      conn =
        put(
          conn,
          Routes.v1_registration_invite_path(
            conn,
            :update,
            registration_invite
          ),
          registration_invite: update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
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

  describe "delete registration_invite with different member" do
    setup [:create_registration_invite_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      registration_invite: registration_invite
    } do
      conn =
        delete(
          conn,
          Routes.v1_registration_invite_path(
            conn,
            :delete,
            registration_invite
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "export registration_invite to CSV" do
    setup [:create_registration_invite_with_responses]

    @tag :authenticated
    test "returns CSV data when requested", %{
      conn: conn,
      registration_invite: %RegistrationInvite{id: id}
    } do
      conn = get(conn, Routes.v1_registration_invite_path(conn, :export, id))

      # Assert content type is CSV
      assert get_content_type(conn) =~ "text/csv"

      # Assert filename in content-disposition header
      assert Plug.Conn.get_resp_header(conn, "content-disposition") ==
               [~s(attachment; filename="registration_invite_#{id}.csv")]

      # Assert CSV content structure (headers and data)
      csv_content = response(conn, 200)

      # Split CSV content into lines
      [headers | rows] = csv_content |> String.split("\r\n") |> Enum.filter(&(&1 != ""))

      # Verify headers
      assert headers =~ "Name"
      assert headers =~ "Email"
      assert headers =~ "Shirt Number"
      assert headers =~ "Shirt Name"

      # Verify we have data rows
      assert length(rows) > 0
    end
  end

  defp create_registration_invite(_) do
    registration_invite = fixture(:registration_invite)
    %{registration_invite: registration_invite}
  end

  defp create_registration_invite_for_team(_) do
    registration_invite = fixture(:registration_invite_for_team)
    %{registration_invite: registration_invite}
  end

  defp create_registration_invite_with_different_member(_) do
    registration_invite = fixture(:registration_invite_with_different_member)
    {:ok, registration_invite: registration_invite}
  end

  defp create_registration_invite_with_responses(_) do
    registration_invite = fixture(:registration_invite_for_team)

    # Add some registration responses for testing
    custom_fields = [
      %{label: "Position", type: "text"},
      %{label: "Age", type: "number"}
    ]

    # Update registration with custom fields
    {:ok, registration} =
      Registrations.update_registration(
        Registrations.get_registration!(registration_invite.registration_id),
        %{custom_fields: custom_fields}
      )

    [custom_field1, custom_field2] = registration.custom_fields

    # Create some responses
    {:ok, _response1} =
      Registrations.create_registration_response(%{
        registration_invite_id: registration_invite.id,
        response: %{
          "name" => "John Doe",
          "email" => "john@example.com",
          "shirt_number" => "23",
          "shirt_name" => "JOHN",
          custom_field1.id => "Guard",
          custom_field2.id => "25"
        }
      })

    {:ok, _response2} =
      Registrations.create_registration_response(%{
        registration_invite_id: registration_invite.id,
        response: %{
          "name" => "Jane Smith",
          "email" => "jane@example.com",
          "shirt_number" => "10",
          "shirt_name" => "JANE",
          custom_field1.id => "Forward",
          custom_field2.id => "24"
        }
      })

    %{registration_invite: registration_invite}
  end

  # Helper function to extract content type
  defp get_content_type(conn) do
    [content_type] = Plug.Conn.get_resp_header(conn, "content-type")
    content_type
  end
end
