defmodule GoChampsApi.Infrastructure.Jobs.AfterTournamentCreationTest do
  alias GoChampsApi.Infrastructure.Jobs.AfterTournamentCreation
  use GoChampsApi.DataCase

  alias GoChampsApi.Sports.Basketball5x5
  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Tournaments

  test "perform/1 update tournament for basketball package" do
    {:ok, tournament} =
      TournamentHelpers.create_simple_tournament(%{sport_slug: "basketball_5x5"})

    {:ok, _tournament} =
      AfterTournamentCreation.perform(%Oban.Job{
        args: %{"tournament_id" => tournament.id}
      })

    updated_tournament = Tournaments.get_tournament!(tournament.id)

    assert Enum.count(updated_tournament.team_stats) ==
             Enum.count(Basketball5x5.Basketball5x5.sport().team_statistics)
  end
end
