defmodule GoChampsApiWeb.RegistrationResponseController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.Registrations
  alias GoChampsApi.Registrations.RegistrationResponse

  action_fallback GoChampsApiWeb.FallbackController

  plug GoChampsApiWeb.Plugs.AuthorizedRegistrationResponse, :id when action in [:delete, :update]

  def index(conn, _params) do
    registration_responses = Registrations.list_registration_responses()
    render(conn, "index.json", registration_responses: registration_responses)
  end

  def create(conn, %{"registration_response" => registration_response_params}) do
    with {:ok, %RegistrationResponse{} = registration_response} <-
           Registrations.create_registration_response(registration_response_params) do
      conn
      |> put_status(:created)
      |> put_resp_header(
        "location",
        Routes.v1_registration_response_path(conn, :show, registration_response)
      )
      |> render("show.json", registration_response: registration_response)
    end
  end

  def show(conn, %{"id" => id}) do
    registration_response = Registrations.get_registration_response!(id)
    render(conn, "show.json", registration_response: registration_response)
  end

  def update(conn, %{"id" => id, "registration_response" => registration_response_params}) do
    registration_response = Registrations.get_registration_response!(id)

    with {:ok, %RegistrationResponse{} = registration_response} <-
           Registrations.update_registration_response(
             registration_response,
             registration_response_params
           ) do
      render(conn, "show.json", registration_response: registration_response)
    end
  end

  def delete(conn, %{"id" => id}) do
    registration_response = Registrations.get_registration_response!(id)

    with {:ok, %RegistrationResponse{}} <-
           Registrations.delete_registration_response(registration_response) do
      send_resp(conn, :no_content, "")
    end
  end
end
