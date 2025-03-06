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
      custom_fields:
        render_many(registration.custom_fields, RegistrationView, "custom_field.json"),
      tournament_id: registration.tournament_id,
      tournament: render_tournament(registration),
      registration_invites: render_registration_invites(registration)
    }
  end

  def render("custom_field.json", %{registration: custom_field}) do
    %{
      id: custom_field.id,
      type: custom_field.type,
      label: custom_field.label,
      description: custom_field.description
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
