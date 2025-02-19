defmodule GoChampsApiWeb.Plugs.AuthorizedRegistrationInvite do
  import Phoenix.Controller
  import Plug.Conn

  alias GoChampsApi.Registrations

  def init(default), do: default

  def call(conn, :registration_invite) do
    {:ok, registration_invite} = Map.fetch(conn.params, "registration_invite")
    {:ok, registration_id} = Map.fetch(registration_invite, "registration_id")

    organization = Registrations.get_registration_organization!(registration_id)
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

  def call(conn, :id) do
    {:ok, registration_invite_id} = Map.fetch(conn.params, "id")

    registration_invite = Registrations.get_registration_invite!(registration_invite_id)

    organization =
      Registrations.get_registration_organization!(registration_invite.registration_id)

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
