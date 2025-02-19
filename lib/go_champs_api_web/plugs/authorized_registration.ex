defmodule GoChampsApiWeb.Plugs.AuthorizedRegistration do
  import Phoenix.Controller
  import Plug.Conn

  alias GoChampsApi.Tournaments
  alias GoChampsApi.Registrations

  def init(default), do: default

  def call(conn, :registration) do
    {:ok, registration} = Map.fetch(conn.params, "registration")
    {:ok, tournament_id} = Map.fetch(registration, "tournament_id")

    organization = Tournaments.get_tournament_organization!(tournament_id)
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
    {:ok, registration_id} = Map.fetch(conn.params, "id")

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
end
