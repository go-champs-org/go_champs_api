defmodule GoChampsApi.Infrastructure.Jobs.ProcessRegistrationInviteTest do
  use GoChampsApi.DataCase
  alias GoChampsApi.Infrastructure.Jobs.ProcessRegistrationInvite

  alias GoChampsApi.Helpers.RegistrationHelpers
  alias GoChampsApi.Helpers.TeamHelpers
  alias GoChampsApi.Registrations
  alias GoChampsApi.Teams

  test "perform/1" do
    registration =
      RegistrationHelpers.create_registration(%{auto_approve: true, type: "team_roster_invites"})

    team =
      TeamHelpers.create_team(%{name: "Team Name", tournament_id: registration.tournament_id})

    {:ok, registration_invite} =
      %{invitee_id: team.id, invitee_type: "team", registration_id: registration.id}
      |> Registrations.create_registration_invite()

    {:ok, _first_registration_response} =
      %{
        response: %{"name" => "First Name", "shirt_number" => "8", "shirt_name" => "F Name"},
        registration_invite_id: registration_invite.id
      }
      |> Registrations.create_registration_response()

    {:ok, _second_registration_response} =
      %{
        response: %{"name" => "Second Name", "shirt_number" => "10", "shirt_name" => "S Name"},
        registration_invite_id: registration_invite.id
      }
      |> Registrations.create_registration_response()

    {:ok, _} =
      ProcessRegistrationInvite.perform(%Oban.Job{
        args: %{
          "registration_invite_id" => registration_invite.id
        }
      })

    team = Teams.get_team_preload!(team.id, [:players])

    assert Enum.count(team.players) == 2
    assert Enum.at(team.players, 0).name == "First Name"
    assert Enum.at(team.players, 0).shirt_number == "8"
    assert Enum.at(team.players, 0).shirt_name == "F Name"
    assert Enum.at(team.players, 1).name == "Second Name"
    assert Enum.at(team.players, 1).shirt_number == "10"
    assert Enum.at(team.players, 1).shirt_name == "S Name"
  end
end
