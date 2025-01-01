import { randomString } from "../utils/random";

const randomPlayer = (tournamentId: string) => ({
  facebook: randomString(),
  instagram: randomString(),
  name: randomString(),
  tournament_id: tournamentId,
  twitter: randomString(),
  username: randomString(),
  shirt_name: randomString(),
  shirt_number: 10,
});

const randomPlayerWithTeam = (tournamentId: string, teamId: string) => ({
  facebook: randomString(),
  instagram: randomString(),
  name: randomString(),
  team_id: teamId,
  tournament_id: tournamentId,
  twitter: randomString(),
  username: randomString(),
  shirt_name: randomString(),
  shirt_number: 10,
});

export const tournamentPlayerPayload = (tournamentId: string) => (
  {
    player: randomPlayer(tournamentId),
  });

export const tournamentPlayerWithTeamPayload = (tournamentId: string, teamId: string) => (
  {
    player: randomPlayerWithTeam(tournamentId, teamId),
  });
  