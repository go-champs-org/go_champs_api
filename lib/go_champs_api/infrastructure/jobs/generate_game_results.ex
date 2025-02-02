defmodule GoChampsApi.Infrastructure.Jobs.GenerateGameResults do
  use Oban.Worker, queue: :generate_game_results

  alias GoChampsApi.Games

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"game_id" => game_id}}) do
    case game_id do
      nil ->
        {:error, "game_id is required"}

      _ ->
        Games.generate_results(game_id)
        {:ok, "Game results has been generated for game #{game_id}"}
    end
  end
end
