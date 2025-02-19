defmodule GoChampsApiWeb.RegistrationInviteController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.Registrations
  alias GoChampsApi.Registrations.RegistrationInvite

  action_fallback GoChampsApiWeb.FallbackController

  def create(conn, %{"registration_invite" => registration_invite_params}) do
    with {:ok, %RegistrationInvite{} = registration_invite} <-
           Registrations.create_registration_invite(registration_invite_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.v1_registration_invite_path(conn, :show, registration_invite)
      )
      |> render("show.json", registration_invite: registration_invite)
    end
  end

  def show(conn, %{"id" => id}) do
    registration_invite = Registrations.get_registration_invite!(id)
    render(conn, "show.json", registration_invite: registration_invite)
  end

  def update(conn, %{"id" => id, "registration_invite" => registration_invite_params}) do
    registration_invite = Registrations.get_registration_invite!(id)

    with {:ok, %RegistrationInvite{} = registration_invite} <-
           Registrations.update_registration_invite(
             registration_invite,
             registration_invite_params
           ) do
      render(conn, "show.json", registration_invite: registration_invite)
    end
  end

  def delete(conn, %{"id" => id}) do
    registration_invite = Registrations.get_registration_invite!(id)

    with {:ok, %RegistrationInvite{}} <-
           Registrations.delete_registration_invite(registration_invite) do
      send_resp(conn, :no_content, "")
    end
  end
end
