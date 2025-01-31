defmodule GoChampsApi.Infrastructure.Jobs.GenerateTeamStatsLogsForGame do
  use Oban.Worker, queue: :generate_team_stats_logs_for_game

  alias GoChampsApi.TeamStatsLogs

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"game_id" => game_id}}) do
    case game_id do
      nil ->
        {:error, "game_id is required"}

      _ ->
        TeamStatsLogs.generate_team_stats_log_from_game_id(game_id)
        {:ok, "Team stats logs generated for game #{game_id}"}
    end
  end
end
