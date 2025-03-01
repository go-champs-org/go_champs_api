defmodule GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdateTest do
  use GoChampsApi.DataCase
  alias GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate

  alias GoChampsApi.Tournaments
  alias GoChampsApi.Helpers.TournamentHelpers

  test "perform/1" do
    {:ok, tournament} = TournamentHelpers.create_simple_tournament()

    :ok =
      ProcessRelevantUpdate.perform(%Oban.Job{
        args: %{
          "tournament_id" => tournament.id
        }
      })

    updated_tournament = Tournaments.get_tournament!(tournament.id)

    assert DateTime.diff(updated_tournament.last_relevant_update_at, DateTime.utc_now(), :second) <
             1
  end
end
