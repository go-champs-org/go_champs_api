defmodule GoChampsApi.RegistrationsTest do
  alias GoChampsApi.Helpers.TeamHelpers
  use GoChampsApi.DataCase
  use Oban.Testing, repo: GoChampsApi.Repo

  alias GoChampsApi.Registrations
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Helpers.RegistrationHelpers
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Teams

  describe "registrations" do
    alias GoChampsApi.Registrations.Registration

    @valid_attrs %{
      auto_approve: true,
      start_date: DateTime.to_iso8601(DateTime.add(DateTime.utc_now(), -10, :day)),
      end_date: DateTime.to_iso8601(DateTime.add(DateTime.utc_now(), 10, :day)),
      title: "some title",
      type: "team_roster_invites"
    }
    @update_attrs %{
      auto_approve: false,
      start_date: DateTime.to_iso8601(DateTime.add(DateTime.utc_now(), -10, :day)),
      end_date: DateTime.to_iso8601(DateTime.add(DateTime.utc_now(), 10, :day)),
      title: "some updated title",
      type: "team_roster_invites"
    }
    @invalid_attrs %{
      auto_approve: nil,
      custom_fields: nil,
      end_date: nil,
      start_date: nil,
      title: nil,
      type: nil
    }

    def registration_fixture(attrs \\ %{}) do
      {:ok, registration} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TournamentHelpers.map_tournament_id()
        |> Registrations.create_registration()

      registration
    end

    test "list_registrations/0 returns all registrations" do
      registration = registration_fixture()
      assert Registrations.list_registrations() == [registration]
    end

    test "get_registration!/1 returns the registration with given id" do
      registration = registration_fixture()
      registration_result = Registrations.get_registration!(registration.id)

      assert registration_result.title == "some title"
      assert registration_result.type == "team_roster_invites"
      assert registration_result.auto_approve == true
      assert registration_result.custom_fields == []

      assert DateTime.to_iso8601(registration_result.end_date) ==
               DateTime.to_iso8601(registration_result.end_date)

      assert DateTime.to_iso8601(registration_result.start_date) ==
               DateTime.to_iso8601(registration.start_date)
    end

    test "get_registration_organization!/1 returns the organization of the registration with given id" do
      registration = registration_fixture()

      organization = Registrations.get_registration_organization!(registration.id)

      tournament = Tournaments.get_tournament!(registration.tournament_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "create_registration/1 with valid data creates a registration" do
      valid_attrs =
        @valid_attrs
        |> TournamentHelpers.map_tournament_id()

      assert {:ok, %Registration{} = registration} =
               Registrations.create_registration(valid_attrs)

      assert registration.auto_approve == true
      assert registration.custom_fields == []

      assert DateTime.to_iso8601(registration.end_date) ==
               DateTime.to_iso8601(registration.end_date)

      assert DateTime.to_iso8601(registration.start_date) ==
               DateTime.to_iso8601(registration.start_date)

      assert registration.title == "some title"
      assert registration.type == "team_roster_invites"
    end

    test "create_registration/1 with invalid type returns error changeset" do
      invalid_attrs =
        @valid_attrs
        |> Map.merge(%{type: "invalid_type"})
        |> TournamentHelpers.map_tournament_id()

      assert {:error, %Ecto.Changeset{}} = Registrations.create_registration(invalid_attrs)
    end

    test "create_registration/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Registrations.create_registration(@invalid_attrs)
    end

    test "update_registration/2 with valid data updates the registration" do
      registration = registration_fixture()

      assert {:ok, %Registration{} = registration} =
               Registrations.update_registration(registration, @update_attrs)

      assert registration.auto_approve == false

      assert DateTime.to_iso8601(registration.end_date) ==
               DateTime.to_iso8601(registration.end_date)

      assert DateTime.to_iso8601(registration.start_date) ==
               DateTime.to_iso8601(registration.start_date)

      assert registration.title == "some updated title"
      assert registration.type == "team_roster_invites"
    end

    test "update_registration/2 with invalid data returns error changeset" do
      registration = registration_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Registrations.update_registration(registration, @invalid_attrs)

      result_registration = Registrations.get_registration!(registration.id)

      assert result_registration.auto_approve == true

      assert DateTime.to_iso8601(result_registration.end_date) ==
               DateTime.to_iso8601(registration.end_date)

      assert DateTime.to_iso8601(result_registration.start_date) ==
               DateTime.to_iso8601(result_registration.start_date)

      assert result_registration.title == "some title"
      assert result_registration.type == "team_roster_invites"
    end

    test "delete_registration/1 deletes the registration" do
      registration = registration_fixture()
      assert {:ok, %Registration{}} = Registrations.delete_registration(registration)
      assert_raise Ecto.NoResultsError, fn -> Registrations.get_registration!(registration.id) end
    end

    test "change_registration/1 returns a registration changeset" do
      registration = registration_fixture()
      assert %Ecto.Changeset{} = Registrations.change_registration(registration)
    end

    test "generate_registration_invites/1 when registration is type of team_roster_invites generates registration invites" do
      registration = registration_fixture()

      team_a =
        TeamHelpers.create_team(%{name: "Team A", tournament_id: registration.tournament_id})

      team_b =
        TeamHelpers.create_team(%{name: "Team B", tournament_id: registration.tournament_id})

      assert {:ok, _registration_invites} =
               Registrations.generate_registration_invites(registration.id)

      updated_registration = Registrations.get_registration!(registration.id)

      assert Enum.count(updated_registration.registration_invites) == 2
      assert Enum.at(updated_registration.registration_invites, 0).invitee_id == team_b.id
      assert Enum.at(updated_registration.registration_invites, 0).invitee_type == "team"
      assert Enum.at(updated_registration.registration_invites, 1).invitee_id == team_a.id
      assert Enum.at(updated_registration.registration_invites, 1).invitee_type == "team"
    end

    test "generate_team_roster_invites/1 generates registration invites for teams" do
      registration = registration_fixture()

      team_a =
        TeamHelpers.create_team(%{name: "Team A", tournament_id: registration.tournament_id})

      team_b =
        TeamHelpers.create_team(%{name: "Team B", tournament_id: registration.tournament_id})

      assert {:ok, registration_invites} =
               Registrations.generate_team_roster_invites(registration)

      assert Enum.count(registration_invites) == 2
      assert Enum.at(registration_invites, 0).invitee_id == team_b.id
      assert Enum.at(registration_invites, 0).invitee_type == "team"
      assert Enum.at(registration_invites, 1).invitee_id == team_a.id
      assert Enum.at(registration_invites, 1).invitee_type == "team"
    end

    test "generate_team_roster_invites/1 does not generate registration invites for teams that have already been invited" do
      registration = registration_fixture()

      team_a =
        TeamHelpers.create_team(%{name: "Team A", tournament_id: registration.tournament_id})

      team_b =
        TeamHelpers.create_team(%{name: "Team B", tournament_id: registration.tournament_id})

      %{
        invitee_id: team_a.id,
        invitee_type: "team",
        registration_id: registration.id
      }
      |> Registrations.create_registration_invite()

      assert {:ok, _registration_invites} =
               Registrations.generate_team_roster_invites(registration)

      registration = Registrations.get_registration!(registration.id)

      assert Enum.count(registration.registration_invites) == 2
      assert Enum.at(registration.registration_invites, 0).invitee_id == team_a.id
      assert Enum.at(registration.registration_invites, 0).invitee_type == "team"
      assert Enum.at(registration.registration_invites, 1).invitee_id == team_b.id
      assert Enum.at(registration.registration_invites, 1).invitee_type == "team"
    end
  end

  describe "registration_invites" do
    alias GoChampsApi.Registrations.RegistrationInvite

    @valid_attrs %{
      invitee_id: Ecto.UUID.autogenerate(),
      invitee_type: "some invitee_type"
    }
    @update_attrs %{
      invitee_id: Ecto.UUID.autogenerate(),
      invitee_type: "some updated invitee_type"
    }
    @invalid_attrs %{invitee_id: nil, invitee_type: nil, registration_id: nil}

    def registration_invite_fixture(attrs \\ %{}) do
      {:ok, registration_invite} =
        attrs
        |> Enum.into(@valid_attrs)
        |> RegistrationHelpers.map_registration_id_in_attrs()
        |> Registrations.create_registration_invite()

      registration_invite
    end

    test "list_registration_invites/0 returns all registration_invites" do
      registration_invite = registration_invite_fixture()
      assert Registrations.list_registration_invites() == [registration_invite]
    end

    test "get_registration_invite!/1 returns the registration_invite with given id" do
      registration_invite = registration_invite_fixture()
      assert Registrations.get_registration_invite!(registration_invite.id) == registration_invite
    end

    test "get_registration_invite/1 returns the registration_invite with invitee preloaded" do
      team = TeamHelpers.create_team()

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          tournament_id: team.tournament_id
        }
        |> RegistrationHelpers.map_registration_id_in_attrs()
        |> Registrations.create_registration_invite()

      registration_invite = Registrations.get_registration_invite!(registration_invite.id)

      assert registration_invite.invitee.name == team.name
      assert registration_invite.invitee.tournament_id == team.tournament_id
      assert registration_invite.invitee.id == registration_invite.invitee_id
    end

    test "get_registration_invite!/1 returns the registration_invite with given id and preloads and invitee" do
      team = TeamHelpers.create_team()

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          tournament_id: team.tournament_id
        }
        |> RegistrationHelpers.map_registration_id_in_attrs()
        |> Registrations.create_registration_invite()

      registration = Registrations.get_registration!(registration_invite.registration_id)

      result = Registrations.get_registration_invite!(registration_invite.id, [:registration])

      assert result.id == registration_invite.id
      assert result.invitee_id == registration_invite.invitee_id
      assert result.invitee_type == registration_invite.invitee_type
      assert result.registration.id == registration.id
      assert result.registration.title == registration.title
      assert result.registration.start_date == registration.start_date
      assert result.registration.end_date == registration.end_date
      assert result.registration.type == registration.type
      assert result.invitee.name == team.name
      assert result.invitee.tournament_id == team.tournament_id
      assert result.invitee.id == team.id
    end

    test "get_registration_invite_invitee/1 returns the invitee of the registration_invite" do
      team = TeamHelpers.create_team()

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          tournament_id: team.tournament_id
        }
        |> RegistrationHelpers.map_registration_id_in_attrs()
        |> Registrations.create_registration_invite()

      invitee = Registrations.get_registration_invite_invitee(registration_invite)

      assert invitee.name == team.name
      assert invitee.tournament_id == team.tournament_id
      assert invitee.id == team.id
    end

    test "get_registration_invite_invitee/1 returns nil if invitee_type is team but invitee_id is not found" do
      registration_invite =
        registration_invite_fixture(%{invitee_type: "team", invitee_id: Ecto.UUID.generate()})

      assert Registrations.get_registration_invite_invitee(registration_invite) == nil
    end

    test "create_registration_invite/1 with valid data creates a registration_invite" do
      valid_attrs =
        @valid_attrs
        |> RegistrationHelpers.map_registration_id_in_attrs()

      assert {:ok, %RegistrationInvite{} = registration_invite} =
               Registrations.create_registration_invite(valid_attrs)

      assert registration_invite.invitee_id == valid_attrs.invitee_id
      assert registration_invite.invitee_type == "some invitee_type"
      assert registration_invite.registration_id == valid_attrs.registration_id
    end

    test "create_registration_invite/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Registrations.create_registration_invite(@invalid_attrs)
    end

    test "update_registration_invite/2 with valid data updates the registration_invite" do
      registration_invite = registration_invite_fixture()

      update_attrs =
        @update_attrs
        |> Map.merge(%{registration_id: registration_invite.registration_id})

      assert {:ok, %RegistrationInvite{} = registration_invite} =
               Registrations.update_registration_invite(registration_invite, update_attrs)

      assert registration_invite.invitee_id == update_attrs.invitee_id
      assert registration_invite.invitee_type == "some updated invitee_type"
      assert registration_invite.registration_id == update_attrs.registration_id
    end

    test "update_registration_invite/2 with invalid data returns error changeset" do
      registration_invite = registration_invite_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Registrations.update_registration_invite(registration_invite, @invalid_attrs)

      assert registration_invite == Registrations.get_registration_invite!(registration_invite.id)
    end

    test "delete_registration_invite/1 deletes the registration_invite" do
      registration_invite = registration_invite_fixture()

      assert {:ok, %RegistrationInvite{}} =
               Registrations.delete_registration_invite(registration_invite)

      assert_raise Ecto.NoResultsError, fn ->
        Registrations.get_registration_invite!(registration_invite.id)
      end
    end

    test "change_registration_invite/1 returns a registration_invite changeset" do
      registration_invite = registration_invite_fixture()
      assert %Ecto.Changeset{} = Registrations.change_registration_invite(registration_invite)
    end

    test "process_registration_invite/1 when registration is auto_approve and type is team_roster_invites" do
      registration = registration_fixture(%{auto_approve: true, type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{invitee_id: team.id, invitee_type: "team", registration_id: registration.id}
        |> Registrations.create_registration_invite()

      {:ok, _first_registration_response} =
        %{
          response: %{
            "name" => "First Name",
            "shirt_number" => "8",
            "shirt_name" => "F Name",
            "email" => "email@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      {:ok, _second_registration_response} =
        %{
          response: %{
            "name" => "Second Name",
            "shirt_number" => "10",
            "shirt_name" => "S Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      :ok = Registrations.process_registration_invite(registration_invite.id)

      team = Teams.get_team_preload!(team.id, [:players])

      sorted_players = Enum.sort_by(team.players, & &1.name)
      assert Enum.count(sorted_players) == 2
      assert Enum.at(sorted_players, 0).name == "First Name"
      assert Enum.at(sorted_players, 0).shirt_number == "8"
      assert Enum.at(sorted_players, 0).shirt_name == "F Name"
      assert Enum.at(sorted_players, 1).name == "Second Name"
      assert Enum.at(sorted_players, 1).shirt_number == "10"
      assert Enum.at(sorted_players, 1).shirt_name == "S Name"
    end
  end

  describe "registration_responses" do
    alias GoChampsApi.Registrations.RegistrationResponse

    @valid_attrs %{response: %{"name" => "John Doe", "email" => "email@go-champs.com"}}
    @update_attrs %{
      response: %{"name" => "Bennie Joe", "email" => "email@go-champs.com"},
      status: "approved"
    }
    @invalid_attrs %{response: nil}

    def registration_response_fixture(attrs \\ %{}) do
      {:ok, registration_response} =
        attrs
        |> Enum.into(@valid_attrs)
        |> RegistrationHelpers.map_registration_invite_id_in_attrs()
        |> Registrations.create_registration_response()

      registration_response
    end

    test "list_registration_responses/0 returns all registration_responses" do
      registration_response = registration_response_fixture()
      assert Registrations.list_registration_responses() == [registration_response]
    end

    test "list_registration_responses/1 returns all registration_responses for given registration_invite_id" do
      registration_response = registration_response_fixture()

      registration_invite_id = registration_response.registration_invite_id

      assert Registrations.list_registration_responses(
               registration_invite_id: registration_invite_id
             ) == [registration_response]
    end

    test "list_registration_responses_by_property/4 returns all registration_responses for given registration_invite_id and property" do
      registration_response = registration_response_fixture()

      registration_invite_id = registration_response.registration_invite_id

      assert Registrations.list_registration_responses_by_property(
               nil,
               registration_invite_id,
               "name",
               "John Doe"
             ) == [registration_response]
    end

    test "get_registration_response!/1 returns the registration_response with given id" do
      registration_response = registration_response_fixture()

      assert Registrations.get_registration_response!(registration_response.id) ==
               registration_response
    end

    test "get_registration_response_organization!/1 returns the organization of the registration with given id" do
      registration_response = registration_response_fixture()

      organization =
        Registrations.get_registration_response_organization!(registration_response.id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
    end

    test "create_registration_response/1 with valid data creates a registration_response" do
      valid_attrs =
        @valid_attrs
        |> RegistrationHelpers.map_registration_invite_id_in_attrs()

      assert {:ok, %RegistrationResponse{} = registration_response} =
               Registrations.create_registration_response(valid_attrs)

      assert registration_response.response == %{
               "name" => "John Doe",
               "email" => "email@go-champs.com"
             }

      assert registration_response.status == "pending"

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.ProcessRegistrationInvite,
        args: %{registration_invite_id: registration_response.registration_invite_id}
      )
    end

    test "create_registration_response/1 for team_roster_invites returns error for duplicated email" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, _} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      {:error, _} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      assert_raise Ecto.NoResultsError, fn ->
        Registrations.get_registration_response!(registration_invite.id)
      end
    end

    test "create_registration_response/1 for team_roster_invites returns error for empty name" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:error, _} =
        %{
          response: %{
            "name" => "",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      assert_raise Ecto.NoResultsError, fn ->
        Registrations.get_registration_response!(registration_invite.id)
      end
    end

    test "create_registration_response/1 for team_roster_invites returns error for empty email" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:error, _} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => ""
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      assert_raise Ecto.NoResultsError, fn ->
        Registrations.get_registration_response!(registration_invite.id)
      end
    end

    test "create_registration_response/1 returns error when registration is out of the active period" do
      registration =
        registration_fixture(%{
          start_date: "2021-04-17T14:00:00Z",
          end_date: "2021-04-17T14:00:00Z"
        })

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:error, _} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      assert_raise Ecto.NoResultsError, fn ->
        Registrations.get_registration_response!(registration_invite.id)
      end
    end

    test "update_registration_response/2 with valid data updates the registration_response" do
      registration_response = registration_response_fixture()

      assert {:ok, %RegistrationResponse{} = registration_response} =
               Registrations.update_registration_response(registration_response, @update_attrs)

      assert registration_response.response == %{
               "name" => "Bennie Joe",
               "email" => "email@go-champs.com"
             }

      assert registration_response.status == "approved"
    end

    test "update_registration_response/2 with invalid data returns error changeset" do
      registration_response = registration_response_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Registrations.update_registration_response(registration_response, @invalid_attrs)

      assert registration_response ==
               Registrations.get_registration_response!(registration_response.id)
    end

    test "delete_registration_response/1 deletes the registration_response" do
      registration_response = registration_response_fixture()

      assert {:ok, %RegistrationResponse{}} =
               Registrations.delete_registration_response(registration_response)

      assert_raise Ecto.NoResultsError, fn ->
        Registrations.get_registration_response!(registration_response.id)
      end
    end

    test "change_registration_response/1 returns a registration_response changeset" do
      registration_response = registration_response_fixture()
      assert %Ecto.Changeset{} = Registrations.change_registration_response(registration_response)
    end

    test "approve_registration_response/1 for a given registration_response id checks if registration is team_roster_invites, creates player and mark registration response as approved" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, registration_response} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "test@test.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      {:ok, _} = Registrations.approve_registration_response(registration_response.id)

      team = Teams.get_team_preload!(team.id, players: :registration_response)

      assert Enum.count(team.players) == 1
      assert Enum.at(team.players, 0).name == "Player Name"
      assert Enum.at(team.players, 0).shirt_number == "8"
      assert Enum.at(team.players, 0).shirt_name == "P Name"
      assert Enum.at(team.players, 0).registration_response_id == registration_response.id

      registration_response = Registrations.get_registration_response!(registration_response.id)

      assert registration_response.status == "approved"
    end

    test "approve_registration_response/1 for a given registration_response id returns error if registration response is not pending" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, registration_response} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id,
          status: "approved"
        }
        |> Registrations.create_registration_response()

      assert Registrations.approve_registration_response(registration_response.id) ==
               {:error, "Registration response is not pending"}
    end

    test "approve_registration_responses/1 for a given array of registration_response ids checks if registration is team_roster_invites, creates players and mark registration responses as approved" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, first_registration_response} =
        %{
          response: %{
            "name" => "First Name",
            "shirt_number" => "8",
            "shirt_name" => "F Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      {:ok, second_registration_response} =
        %{
          response: %{
            "name" => "Second Name",
            "shirt_number" => "10",
            "shirt_name" => "S Name",
            "email" => "test1@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      [{:ok, _}, {:ok, _}] =
        Registrations.approve_registration_responses([
          first_registration_response.id,
          second_registration_response.id
        ])

      team = Teams.get_team_preload!(team.id, players: :registration_response)

      assert Enum.count(team.players) == 2
      assert Enum.at(team.players, 0).name == "First Name"
      assert Enum.at(team.players, 0).shirt_number == "8"
      assert Enum.at(team.players, 0).shirt_name == "F Name"
      assert Enum.at(team.players, 0).registration_response_id == first_registration_response.id
      assert Enum.at(team.players, 1).name == "Second Name"
      assert Enum.at(team.players, 1).shirt_number == "10"
      assert Enum.at(team.players, 1).shirt_name == "S Name"
      assert Enum.at(team.players, 1).registration_response_id == second_registration_response.id
    end

    test "approve_registration_responses_for_registration_invite/1 when registration type is team_roster_invites, create player on invitee team and mark registration_response as approved" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, registration_response} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "test@test.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      [{:ok, _}] =
        Registrations.approve_registration_responses_for_registration_invite(
          registration_invite.id
        )

      team = Teams.get_team_preload!(team.id, players: :registration_response)

      assert Enum.count(team.players) == 1
      assert Enum.at(team.players, 0).name == "Player Name"
      assert Enum.at(team.players, 0).shirt_number == "8"
      assert Enum.at(team.players, 0).shirt_name == "P Name"
      assert Enum.at(team.players, 0).registration_response_id == registration_response.id

      registration_response = Registrations.get_registration_response!(registration_response.id)

      assert registration_response.status == "approved"
    end

    test "approve_registration_responses_for_registration_invite/1 when registration type is team_roster_invites, create players on invitee team and mark as registration_responses as approved" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, first_registration_response} =
        %{
          response: %{
            "name" => "First Name",
            "shirt_number" => "8",
            "shirt_name" => "F Name",
            "email" => "email@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      {:ok, second_registration_response} =
        %{
          response: %{
            "name" => "Second Name",
            "shirt_number" => "10",
            "shirt_name" => "S Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      [_, _] =
        Registrations.approve_registration_responses_for_registration_invite(
          registration_invite.id
        )

      team = Teams.get_team_preload!(team.id, players: :registration_response)

      assert Enum.count(team.players) == 2
      assert Enum.at(team.players, 0).name == "First Name"
      assert Enum.at(team.players, 0).shirt_number == "8"
      assert Enum.at(team.players, 0).shirt_name == "F Name"
      assert Enum.at(team.players, 0).registration_response_id == first_registration_response.id
      assert Enum.at(team.players, 1).name == "Second Name"
      assert Enum.at(team.players, 1).shirt_number == "10"
      assert Enum.at(team.players, 1).shirt_name == "S Name"
      assert Enum.at(team.players, 1).registration_response_id == second_registration_response.id

      first_registration_response =
        Registrations.get_registration_response!(first_registration_response.id)

      second_registration_response =
        Registrations.get_registration_response!(second_registration_response.id)

      assert first_registration_response.status == "approved"
      assert second_registration_response.status == "approved"
    end

    test "approve_registration_responses_for_registration_invite/1 when registration type is team_roster_invites, does not create player on invitee team if response is approved" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, registration_response} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "email@go-champs.com"
          },
          registration_invite_id: registration_invite.id,
          status: "approved"
        }
        |> Registrations.create_registration_response()

      [] =
        Registrations.approve_registration_responses_for_registration_invite(
          registration_invite.id
        )

      team = Teams.get_team_preload!(team.id, [:players])

      assert Enum.count(team.players) == 0

      registration_response = Registrations.get_registration_response!(registration_response.id)

      assert registration_response.status == "approved"
    end

    test "approve_team_roster_response/1 creates a player in the invitee team and mark response as approved" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, registration_response} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "test@go-champs.com"
          },
          registration_invite_id: registration_invite.id
        }
        |> Registrations.create_registration_response()

      {:ok, _} = Registrations.approve_team_roster_response(registration_response)

      team = Teams.get_team_preload!(team.id, [:players])

      assert Enum.count(team.players) == 1
      assert Enum.at(team.players, 0).name == "Player Name"
      assert Enum.at(team.players, 0).shirt_number == "8"
      assert Enum.at(team.players, 0).shirt_name == "P Name"

      registration_response = Registrations.get_registration_response!(registration_response.id)

      assert registration_response.status == "approved"
    end

    test "approve_team_roster_response/1 does not create a player in the invitee team if response is approved" do
      registration = registration_fixture(%{type: "team_roster_invites"})

      team =
        TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

      {:ok, registration_invite} =
        %{
          invitee_id: team.id,
          invitee_type: "team",
          registration_id: registration.id
        }
        |> Registrations.create_registration_invite()

      {:ok, registration_response} =
        %{
          response: %{
            "name" => "Player Name",
            "shirt_number" => "8",
            "shirt_name" => "P Name",
            "email" => "email@go-champs.com"
          },
          registration_invite_id: registration_invite.id,
          status: "approved"
        }
        |> Registrations.create_registration_response()

      :ok = Registrations.approve_team_roster_response(registration_response)

      team = Teams.get_team_preload!(team.id, [:players])

      assert Enum.count(team.players) == 0

      registration_response = Registrations.get_registration_response!(registration_response.id)

      assert registration_response.status == "approved"
    end
  end
end
