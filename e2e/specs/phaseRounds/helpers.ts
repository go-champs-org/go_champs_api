import { randomString } from "../utils/random";

const randomRound = (tournamentPhaseId: string) => ({
  matches: [
    {
      first_team_id: "some-first-team-id",
      first_team_parent_id: "some-first-team-parent-id",
      first_team_placeholder: "some-first-team-placeholder",
      first_team_score: "some-first-team-score",
      second_team_id: "some-second-team-id",
      second_team_parent_id: "some-second-team-parent-id",
      second_team_placeholder: "some-second-team-placeholder",
      second_team_score: "some-second-team-score",
    },
  ],
  title: randomString(),
  tournament_phase_id: tournamentPhaseId,
});

export const tournamentRoundPayload = (tournamentPhaseId: string) => (
  {
    phase_round: randomRound(tournamentPhaseId),
  });
