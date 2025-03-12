defmodule GoChampsApi.ScoreboardSettingsTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.ScoreboardSettings

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Tournaments

  describe "scoreboard_settings" do
    alias GoChampsApi.ScoreboardSettings.ScoreboardSetting

    @valid_attrs %{view: "basketball-basic"}
    @update_attrs %{view: "basketball-medium"}
    @invalid_attrs %{view: nil}

    def scoreboard_setting_fixture(attrs \\ %{}) do
      {:ok, scoreboard_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TournamentHelpers.map_tournament_id()
        |> ScoreboardSettings.create_scoreboard_setting()

      scoreboard_setting
    end

    test "list_scoreboard_settings/0 returns all scoreboard_settings" do
      scoreboard_setting = scoreboard_setting_fixture()
      assert ScoreboardSettings.list_scoreboard_settings() == [scoreboard_setting]
    end

    test "get_scoreboard_setting!/1 returns the scoreboard_setting with given id" do
      scoreboard_setting = scoreboard_setting_fixture()

      assert ScoreboardSettings.get_scoreboard_setting!(scoreboard_setting.id) ==
               scoreboard_setting
    end

    test "get_scoreboard_setting_organization!/1 returns the organization of the scoreboard_setting" do
      scoreboard_setting = scoreboard_setting_fixture()

      organization =
        ScoreboardSettings.get_scoreboard_setting_organization!(scoreboard_setting.id)

      tournament = Tournaments.get_tournament!(scoreboard_setting.tournament_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == tournament.organization_id
    end

    test "create_scoreboard_setting/1 with valid data creates a scoreboard_setting" do
      valid_attrs = TournamentHelpers.map_tournament_id(@valid_attrs)

      assert {:ok, %ScoreboardSetting{} = scoreboard_setting} =
               ScoreboardSettings.create_scoreboard_setting(valid_attrs)

      assert scoreboard_setting.view == "basketball-basic"
    end

    test "create_scoreboard_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               ScoreboardSettings.create_scoreboard_setting(@invalid_attrs)
    end

    test "update_scoreboard_setting/2 with valid data updates the scoreboard_setting" do
      scoreboard_setting = scoreboard_setting_fixture()

      assert {:ok, %ScoreboardSetting{} = scoreboard_setting} =
               ScoreboardSettings.update_scoreboard_setting(scoreboard_setting, @update_attrs)

      assert scoreboard_setting.view == "basketball-medium"
    end

    test "update_scoreboard_setting/2 with invalid data returns error changeset" do
      scoreboard_setting = scoreboard_setting_fixture()

      assert {:error, %Ecto.Changeset{}} =
               ScoreboardSettings.update_scoreboard_setting(scoreboard_setting, @invalid_attrs)

      assert scoreboard_setting ==
               ScoreboardSettings.get_scoreboard_setting!(scoreboard_setting.id)
    end

    test "delete_scoreboard_setting/1 deletes the scoreboard_setting" do
      scoreboard_setting = scoreboard_setting_fixture()

      assert {:ok, %ScoreboardSetting{}} =
               ScoreboardSettings.delete_scoreboard_setting(scoreboard_setting)

      assert_raise Ecto.NoResultsError, fn ->
        ScoreboardSettings.get_scoreboard_setting!(scoreboard_setting.id)
      end
    end

    test "change_scoreboard_setting/1 returns a scoreboard_setting changeset" do
      scoreboard_setting = scoreboard_setting_fixture()
      assert %Ecto.Changeset{} = ScoreboardSettings.change_scoreboard_setting(scoreboard_setting)
    end
  end
end
