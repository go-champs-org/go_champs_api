defmodule GoChampsApi.RegistrationsTest do
  alias GoChampsApi.Helpers.TeamHelpers
  use GoChampsApi.DataCase

  alias GoChampsApi.Registrations
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Helpers.RegistrationHelpers
  alias GoChampsApi.Tournaments

  describe "registrations" do
    alias GoChampsApi.Registrations.Registration

    @valid_attrs %{
      auto_approve: true,
      end_date: "2010-04-17T14:00:00Z",
      start_date: "2010-04-17T14:00:00Z",
      title: "some title",
      type: "team_roster_invites"
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

      assert registration_result.end_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert registration_result.start_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
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
      assert registration.end_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert registration.start_date == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
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
      assert registration.end_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert registration.start_date == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert registration.title == "some updated title"
      assert registration.type == "team_roster_invites"
    end

    test "update_registration/2 with invalid data returns error changeset" do
      registration = registration_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Registrations.update_registration(registration, @invalid_attrs)

      result_registration = Registrations.get_registration!(registration.id)

      assert result_registration.auto_approve == true

      assert result_registration.end_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

      assert result_registration.start_date ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")

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
  end

  describe "registration_invites" do
    alias GoChampsApi.Registrations.RegistrationInvite

    @valid_attrs %{
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
  end
end
