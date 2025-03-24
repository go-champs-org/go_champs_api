defmodule GoChampsApiWeb.PlayerView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.PlayerView
  alias GoChampsApiWeb.RegistrationResponseView

  def render("index.json", %{players: players}) do
    %{data: render_many(players, PlayerView, "player.json")}
  end

  def render("show.json", %{player: player}) do
    %{data: render_one(player, PlayerView, "player.json")}
  end

  def render("player.json", %{player: player}) do
    %{
      id: player.id,
      name: player.name,
      username: player.username,
      facebook: player.facebook,
      instagram: player.instagram,
      twitter: player.twitter,
      team_id: player.team_id,
      shirt_number: player.shirt_number,
      shirt_name: player.shirt_name,
      registration_response: render_player_registration_response(player.registration_response),
      state: player.state
    }
  end

  defp render_player_registration_response(nil), do: nil

  defp render_player_registration_response(registration_response) do
    if Ecto.assoc_loaded?(registration_response) do
      render_one(registration_response, RegistrationResponseView, "registration_response.json")
    else
      nil
    end
  end
end
