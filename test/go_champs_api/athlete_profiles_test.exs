defmodule GoChampsApi.AthleteProfilesTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.AthleteProfiles

  describe "athlete_profiles" do
    alias GoChampsApi.AthleteProfiles.AthleteProfile
    @valid_attrs %{
      username: "john_doe",
      name: "John Doe",
      photo: "https://example.com/photo.jpg",
      facebook: "https://www.facebook.com/johndoe",
      instagram: "https://www.instagram.com/johndoe",
      twitter: "https://www.twitter.com/johndoe"
    }
    @update_attrs %{
      username: "updated_username",
      name: "Updated Name",
      photo: "https://example.com/updated_photo.jpg",
      facebook: "https://www.facebook.com/updated",
      instagram: "https://www.instagram.com/updated",
      twitter: "https://www.twitter.com/updated"
    }
    @invalid_attrs %{username: nil, name: nil}

    def athlete_profile_fixture(attrs \\ %{}) do
      {:ok, athlete_profile} =
        attrs
        |> Enum.into(@valid_attrs)
        |> AthleteProfiles.create_athlete_profile()

      athlete_profile
    end

    test "list_athlete_profiles/0 returns all athlete_profiles" do
      athlete_profile = athlete_profile_fixture()
      assert AthleteProfiles.list_athlete_profiles() == [athlete_profile]
    end

    test "get_athlete_profile!/1 returns the athlete_profile with given id" do
      athlete_profile = athlete_profile_fixture()
      assert AthleteProfiles.get_athlete_profile!(athlete_profile.id) == athlete_profile
    end

    test "get_athlete_profile_by_username/1 returns the athlete_profile with given username" do
      athlete_profile = athlete_profile_fixture()
      assert AthleteProfiles.get_athlete_profile_by_username(athlete_profile.username) == athlete_profile
    end

    test "get_athlete_profile_by_username/1 returns nil when username does not exist" do
      assert AthleteProfiles.get_athlete_profile_by_username("nonexistent") == nil
    end

    test "create_athlete_profile/1 with valid data creates a athlete_profile" do
      assert {:ok, %AthleteProfile{} = athlete_profile} = AthleteProfiles.create_athlete_profile(@valid_attrs)
      assert athlete_profile.username == "john_doe"
      assert athlete_profile.name == "John Doe"
      assert athlete_profile.photo == "https://example.com/photo.jpg"
      assert athlete_profile.facebook == "https://www.facebook.com/johndoe"
      assert athlete_profile.instagram == "https://www.instagram.com/johndoe"
      assert athlete_profile.twitter == "https://www.twitter.com/johndoe"
    end

    test "create_athlete_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = AthleteProfiles.create_athlete_profile(@invalid_attrs)
    end

    test "create_athlete_profile/1 with duplicate username returns error changeset" do
      athlete_profile_fixture()

      assert {:error, %Ecto.Changeset{}} = AthleteProfiles.create_athlete_profile(@valid_attrs)
    end

    test "update_athlete_profile/2 with valid data updates the athlete_profile" do
      athlete_profile = athlete_profile_fixture()

      assert {:ok, %AthleteProfile{} = athlete_profile} = AthleteProfiles.update_athlete_profile(athlete_profile, @update_attrs)
      assert athlete_profile.username == "updated_username"
      assert athlete_profile.name == "Updated Name"
      assert athlete_profile.photo == "https://example.com/updated_photo.jpg"
      assert athlete_profile.facebook == "https://www.facebook.com/updated"
      assert athlete_profile.instagram == "https://www.instagram.com/updated"
      assert athlete_profile.twitter == "https://www.twitter.com/updated"
    end

    test "update_athlete_profile/2 with invalid data returns error changeset" do
      athlete_profile = athlete_profile_fixture()
      assert {:error, %Ecto.Changeset{}} = AthleteProfiles.update_athlete_profile(athlete_profile, @invalid_attrs)
      assert athlete_profile == AthleteProfiles.get_athlete_profile!(athlete_profile.id)
    end

    test "delete_athlete_profile/1 deletes the athlete_profile" do
      athlete_profile = athlete_profile_fixture()
      assert {:ok, %AthleteProfile{}} = AthleteProfiles.delete_athlete_profile(athlete_profile)
      assert_raise Ecto.NoResultsError, fn -> AthleteProfiles.get_athlete_profile!(athlete_profile.id) end
    end

    test "change_athlete_profile/1 returns a athlete_profile changeset" do
      athlete_profile = athlete_profile_fixture()
      assert %Ecto.Changeset{} = AthleteProfiles.change_athlete_profile(athlete_profile)
    end
  end
end
