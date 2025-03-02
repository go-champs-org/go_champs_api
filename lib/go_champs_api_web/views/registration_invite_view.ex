defmodule GoChampsApiWeb.RegistrationInviteView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.RegistrationInviteView
  alias GoChampsApiWeb.RegistrationView
  alias GoChampsApiWeb.RegistrationResponseView

  def render("index.json", %{registration_invites: registration_invites}) do
    %{data: render_many(registration_invites, RegistrationInviteView, "registration_invite.json")}
  end

  def render("show.json", %{registration_invite: registration_invite}) do
    %{data: render_one(registration_invite, RegistrationInviteView, "registration_invite.json")}
  end

  def render("registration_invite.json", %{registration_invite: registration_invite}) do
    %{
      id: registration_invite.id,
      invitee_type: registration_invite.invitee_type,
      invitee_id: registration_invite.invitee_id,
      invitee: render_invitee(registration_invite),
      registration_id: registration_invite.registration_id,
      registration: render_registration(registration_invite),
      registration_responses: render_registration_responses(registration_invite)
    }
  end

  defp render_registration(registration_invite) do
    if Ecto.assoc_loaded?(registration_invite.registration) do
      render_one(registration_invite.registration, RegistrationView, "registration.json")
    else
      nil
    end
  end

  defp render_registration_responses(registration_invite) do
    if Ecto.assoc_loaded?(registration_invite.registration_responses) do
      render_many(
        registration_invite.registration_responses,
        RegistrationResponseView,
        "registration_response.json"
      )
    else
      []
    end
  end

  defp render_invitee(registration_invite) do
    case registration_invite.invitee_type do
      "team" ->
        render_one(
          registration_invite.invitee,
          GoChampsApiWeb.TeamView,
          "team.json"
        )

      _ ->
        nil
    end
  end
end
