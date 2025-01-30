defmodule GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame do
  use Oban.Worker, queue: :generate_team_stats_logs_for_game

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"game_id" => game_id}}) do
    IO.inspect("Generating team stats logs for game #{game_id}")
  end
end
