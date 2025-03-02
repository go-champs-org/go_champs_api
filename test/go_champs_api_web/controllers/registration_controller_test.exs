defmodule GoChampsApiWeb.RegistrationControllerTest do
  alias GoChampsApi.Helpers.TeamHelpers
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.Registrations
  alias GoChampsApi.Registrations.Registration

  alias GoChampsApi.Helpers.TournamentHelpers

  @create_attrs %{
    auto_approve: true,
    end_date: "2010-04-17T14:00:00Z",
    start_date: "2010-04-17T14:00:00Z",
    title: "some title",
    type: "team_roster_invites",
    custom_fields: [
      %{
        type: "text",
        label: "Team Name",
        description: "The name of the team"
      }
    ]
  }
  @update_attrs %{
    auto_approve: false,
    end_date: "2011-05-18T15:01:01Z",
    start_date: "2011-05-18T15:01:01Z",
    title: "some updated title",
    type: "team_roster_invites"
  }
  @invalid_attrs %{
    auto_approve: nil,
    end_date: nil,
    start_date: nil,
    title: nil,
    type: nil
  }

  def fixture(:registration) do
    create_attrs =
      @create_attrs
      |> TournamentHelpers.map_tournament_id()

    {:ok, registration} = Registrations.create_registration(create_attrs)
    registration
  end

  def fixture(:registration_with_different_member) do
    create_attrs =
      @create_attrs
      |> TournamentHelpers.map_tournament_id_with_other_member()

    {:ok, registration} = Registrations.create_registration(create_attrs)
    registration
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all registrations", %{conn: conn} do
      conn = get(conn, Routes.v1_registration_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create registration" do
    @tag :authenticated
    test "renders registration when data is valid", %{conn: conn} do
      create_attrs =
        @create_attrs
        |> TournamentHelpers.map_tournament_id()

      conn = post(conn, Routes.v1_registration_path(conn, :create), registration: create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_registration_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "auto_approve" => true,
               "end_date" => "2010-04-17T14:00:00Z",
               "start_date" => "2010-04-17T14:00:00Z",
               "title" => "some title",
               "type" => "team_roster_invites"
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn} do
      invalid_attrs =
        @invalid_attrs
        |> TournamentHelpers.map_tournament_id()

      conn = post(conn, Routes.v1_registration_path(conn, :create), registration: invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "create registration with different organization member" do
    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{conn: conn} do
      attrs = TournamentHelpers.map_tournament_id_with_other_member(@create_attrs)

      conn = post(conn, Routes.v1_registration_path(conn, :create), registration: attrs)

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "update registration" do
    setup [:create_registration]

    @tag :authenticated
    test "renders registration when data is valid", %{
      conn: conn,
      registration: %Registration{id: id} = registration
    } do
      conn =
        put(conn, Routes.v1_registration_path(conn, :update, registration),
          registration: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_registration_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "auto_approve" => false,
               "end_date" => "2011-05-18T15:01:01Z",
               "start_date" => "2011-05-18T15:01:01Z",
               "title" => "some updated title",
               "type" => "team_roster_invites"
             } = json_response(conn, 200)["data"]
    end

    @tag :authenticated
    test "renders errors when data is invalid", %{conn: conn, registration: registration} do
      conn =
        put(conn, Routes.v1_registration_path(conn, :update, registration),
          registration: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update registration with different member" do
    setup [:create_registration_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      registration: registration
    } do
      conn =
        put(
          conn,
          Routes.v1_registration_path(
            conn,
            :update,
            registration
          ),
          registration: @update_attrs
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  describe "delete registration" do
    setup [:create_registration]

    @tag :authenticated
    test "deletes chosen registration", %{conn: conn, registration: registration} do
      conn = delete(conn, Routes.v1_registration_path(conn, :delete, registration))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_registration_path(conn, :show, registration))
      end
    end
  end

  describe "put /registration/{id}/generate-invites" do
    setup [:create_registration]

    @tag :authenticated
    test "generates invites for the registration", %{conn: conn, registration: registration} do
      team_a =
        TeamHelpers.create_team(%{name: "Team A", tournament_id: registration.tournament_id})

      team_b =
        TeamHelpers.create_team(%{name: "Team B", tournament_id: registration.tournament_id})

      conn = put(conn, Routes.v1_registration_path(conn, :generate_invites, registration))
      assert response(conn, 200)

      conn = get(conn, Routes.v1_registration_path(conn, :show, registration.id))
      response = json_response(conn, 200)["data"]

      registration_id = registration.id
      tournament_id = registration.tournament_id
      team_a_id = team_a.id
      team_b_id = team_b.id

      assert response["id"] == registration_id
      assert response["auto_approve"] == true
      assert response["end_date"] == "2010-04-17T14:00:00Z"
      assert response["start_date"] == "2010-04-17T14:00:00Z"
      assert response["title"] == "some title"
      assert response["type"] == "team_roster_invites"
      assert Enum.at(response["custom_fields"], 0)["description"] == "The name of the team"
      assert Enum.at(response["custom_fields"], 0)["label"] == "Team Name"
      assert Enum.at(response["custom_fields"], 0)["type"] == "text"

      assert response["tournament_id"] == tournament_id

      registration_invites = response["registration_invites"]

      assert length(registration_invites) == 2
      assert Enum.at(registration_invites, 0)["registration_id"] == registration_id
      assert Enum.at(registration_invites, 0)["invitee_id"] == team_b_id
      assert Enum.at(registration_invites, 0)["invitee_type"] == "team"
      assert Enum.at(registration_invites, 1)["registration_id"] == registration_id
      assert Enum.at(registration_invites, 1)["invitee_id"] == team_a_id
      assert Enum.at(registration_invites, 1)["invitee_type"] == "team"
    end
  end

  describe "delete registration with different member" do
    setup [:create_registration_with_different_member]

    @tag :authenticated
    test "returns forbidden for an user that is not a member", %{
      conn: conn,
      registration: registration
    } do
      conn =
        delete(
          conn,
          Routes.v1_registration_path(
            conn,
            :delete,
            registration
          )
        )

      assert text_response(conn, 403) == "Forbidden"
    end
  end

  defp create_registration(_) do
    registration = fixture(:registration)
    %{registration: registration}
  end

  defp create_registration_with_different_member(_) do
    registration = fixture(:registration_with_different_member)
    {:ok, registration: registration}
  end
end
