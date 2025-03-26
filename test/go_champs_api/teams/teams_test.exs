defmodule GoChampsApi.TeamsTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Teams
  alias GoChampsApi.Teams.Team
  alias GoChampsApi.Tournaments

  describe "teams" do
    alias GoChampsApi.Teams.Team

    @valid_attrs %{
      name: "some name",
      logo_url: "https://www.example.com/logo.png",
      tri_code: "TST"
    }
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def team_fixture(attrs \\ %{}) do
      {:ok, team} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TournamentHelpers.map_tournament_id()
        |> Teams.create_team()

      team
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Teams.get_team!(team.id) == team
    end

    test "get_team_organization!/1 returns the organization with a give team id" do
      team = team_fixture()

      organization = Teams.get_team_organization!(team.id)

      tournament = Tournaments.get_tournament!(team.tournament_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = TournamentHelpers.map_tournament_id(@valid_attrs)
      assert {:ok, %Team{} = team} = Teams.create_team(valid_attrs)
      assert team.name == "some name"
      assert team.logo_url == "https://www.example.com/logo.png"
      assert team.tri_code == "TST"
    end

    test "create_team/1 with invalid data returns error changeset" do
      invalid_attrs = TournamentHelpers.map_tournament_id(@invalid_attrs)
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      assert {:ok, %Team{} = team} = Teams.update_team(team, @update_attrs)
      assert team.name == "some updated name"
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end
end
