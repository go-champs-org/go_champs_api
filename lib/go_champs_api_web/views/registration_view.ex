defmodule GoChampsApiWeb.RegistrationView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.RegistrationView

  alias GoChampsApiWeb.RegistrationInviteView
  alias GoChampsApiWeb.TournamentView

  def render("index.json", %{registrations: registrations}) do
    %{data: render_many(registrations, RegistrationView, "registration.json")}
  end

  def render("show.json", %{registration: registration}) do
    %{data: render_one(registration, RegistrationView, "registration.json")}
  end

  def render("registration.json", %{registration: registration}) do
    %{
      id: registration.id,
      title: registration.title,
      start_date: registration.start_date,
      end_date: registration.end_date,
      type: registration.type,
      auto_approve: registration.auto_approve,
      custom_fields: registration.custom_fields,
      tournament_id: registration.tournament_id,
      tournament: render_tournament(registration),
      registration_invites: render_registration_invites(registration)
    }
  end

  defp render_registration_invites(registration) do
    if Ecto.assoc_loaded?(registration.registration_invites) do
      render_many(
        registration.registration_invites,
        RegistrationInviteView,
        "registration_invite.json"
      )
    else
      []
    end
  end

  defp render_tournament(registration) do
    if Ecto.assoc_loaded?(registration.tournament) do
      render_one(registration.tournament, TournamentView, "tournament.json")
    else
      nil
    end
  end
end
