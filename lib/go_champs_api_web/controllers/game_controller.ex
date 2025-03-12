defmodule GoChampsApiWeb.GameController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.Games
  alias GoChampsApi.Games.Game

  action_fallback GoChampsApiWeb.FallbackController

  plug GoChampsApiWeb.Plugs.AuthorizedGame, :game when action in [:create]
  plug GoChampsApiWeb.Plugs.AuthorizedGame, :id when action in [:delete, :update, :verify_access]

  defp map_to_keyword(map) do
    Enum.map(map, fn {key, value} -> {String.to_atom(key), value} end)
  end

  def index(conn, params) do
    games =
      case params do
        %{"where" => where} ->
          where
          |> map_to_keyword()
          |> Games.list_games()

        _ ->
          # TODO (lairjr): Return error if no filter is provided
          []
      end

    render(conn, "index.json", games: games)
  end

  def create(conn, %{"game" => game_params}) do
    with {:ok, %Game{} = created_game} <- Games.create_game(game_params) do
      game = Games.get_game!(created_game.id)

      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.game_path(conn, :show, game))
      |> render("show.json", game: game)
    end
  end

  def show(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    render(conn, "show.json", game: game)
  end

  def verify_access(conn, %{"id" => id}) do
    game = Games.get_game!(id)
    render(conn, "show.json", game: game)
  end

  def scoreboard_setting(conn, %{"id" => id}) do
    scoreboard_setting = Games.get_game_scoreboard_setting!(id)

    conn
    |> put_view(GoChampsApiWeb.ScoreboardSettingView)
    |> render(:show, scoreboard_setting: scoreboard_setting)
  end

  def update(conn, %{"id" => id, "game" => game_params}) do
    game = Games.get_game!(id)

    with {:ok, %Game{} = game} <- Games.update_game(game, game_params) do
      render(conn, "show.json", game: game)
    end
  end

  def delete(conn, %{"id" => id}) do
    game = Games.get_game!(id)

    with {:ok, %Game{}} <- Games.delete_game(game) do
      send_resp(conn, :no_content, "")
    end
  end
end
