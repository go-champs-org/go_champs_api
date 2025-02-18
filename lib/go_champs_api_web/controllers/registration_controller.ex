defmodule GoChampsApiWeb.RegistrationController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.Registrations
  alias GoChampsApi.Registrations.Registration

  action_fallback GoChampsApiWeb.FallbackController

  def index(conn, _params) do
    registrations = Registrations.list_registrations()
    render(conn, "index.json", registrations: registrations)
  end

  def create(conn, %{"registration" => registration_params}) do
    with {:ok, %Registration{} = registration} <-
           Registrations.create_registration(registration_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.v1_registration_path(conn, :show, registration))
      |> render("show.json", registration: registration)
    end
  end

  def show(conn, %{"id" => id}) do
    registration = Registrations.get_registration!(id)
    render(conn, "show.json", registration: registration)
  end

  def update(conn, %{"id" => id, "registration" => registration_params}) do
    registration = Registrations.get_registration!(id)

    with {:ok, %Registration{} = registration} <-
           Registrations.update_registration(registration, registration_params) do
      render(conn, "show.json", registration: registration)
    end
  end

  def delete(conn, %{"id" => id}) do
    registration = Registrations.get_registration!(id)

    with {:ok, %Registration{}} <- Registrations.delete_registration(registration) do
      send_resp(conn, :no_content, "")
    end
  end
end
