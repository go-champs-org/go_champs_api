defmodule GoChampsApiWeb.PlayerView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.PlayerView

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
      twitter: player.twitter
    }
  end
end
