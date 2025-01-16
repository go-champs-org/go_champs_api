defmodule GoChampsApiWeb.GameView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.GameView
  alias GoChampsApiWeb.TeamView

  def render("index.json", %{games: games}) do
    %{data: render_many(games, GameView, "game.json")}
  end

  def render("show.json", %{game: game}) do
    %{data: render_one(game, GameView, "game.json")}
  end

  def render("game.json", %{game: game}) do
    %{
      id: game.id,
      away_placeholder: game.away_placeholder,
      away_score: game.away_score,
      away_team: render_one(game.away_team, TeamView, "team.json"),
      datetime: game.datetime,
      phase_id: game.phase_id,
      home_placeholder: game.home_placeholder,
      home_score: game.home_score,
      home_team: render_one(game.home_team, TeamView, "team.json"),
      info: game.info,
      is_finished: game.is_finished,
      live_state: game.live_state,
      live_started_at: game.live_started_at,
      live_ended_at: game.live_ended_at,
      location: game.location,
      youtube_code: game.youtube_code
    }
  end
end
