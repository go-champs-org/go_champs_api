defmodule GoChampsApiWeb.RegistrationView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.RegistrationView

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
      tournament_id: registration.tournament_id
    }
  end
end
