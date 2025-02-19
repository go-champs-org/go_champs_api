defmodule GoChampsApiWeb.RegistrationInviteView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.RegistrationInviteView

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
      registration_id: registration_invite.registration_id
    }
  end
end
