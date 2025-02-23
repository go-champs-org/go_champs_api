defmodule GoChampsApiWeb.Plugs.AuthorizedRegistrationResponse do
  import Phoenix.Controller
  import Plug.Conn

  alias GoChampsApi.Registrations

  def init(default), do: default

  def call(conn, :id) do
    {:ok, registration_response_id} = Map.fetch(conn.params, "id")

    organization = Registrations.get_registration_response_organization!(registration_response_id)
    current_user = Guardian.Plug.current_resource(conn)

    if Enum.any?(organization.members, fn member -> member.username == current_user.username end) do
      conn
    else
      conn
      |> put_status(:forbidden)
      |> text("Forbidden")
      |> halt
    end
  end
end
