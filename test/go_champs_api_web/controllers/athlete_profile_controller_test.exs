defmodule GoChampsApiWeb.AthleteProfileControllerTest do
  use GoChampsApiWeb.ConnCase

  alias GoChampsApi.AthleteProfiles
  alias GoChampsApi.AthleteProfiles.AthleteProfile

  @create_attrs %{
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

  def fixture(:athlete_profile) do
    {:ok, athlete_profile} = AthleteProfiles.create_athlete_profile(@create_attrs)
    athlete_profile
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all athlete_profiles", %{conn: conn} do
      conn = get(conn, Routes.v1_athlete_profile_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create athlete_profile" do
    test "renders athlete_profile when data is valid", %{conn: conn} do
      conn = post(conn, Routes.v1_athlete_profile_path(conn, :create), athlete_profile: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.v1_athlete_profile_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "username" => "john_doe",
               "name" => "John Doe",
               "photo" => "https://example.com/photo.jpg",
               "facebook" => "https://www.facebook.com/johndoe",
               "instagram" => "https://www.instagram.com/johndoe",
               "twitter" => "https://www.twitter.com/johndoe"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.v1_athlete_profile_path(conn, :create), athlete_profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show" do
    setup [:create_athlete_profile]

    test "renders athlete_profile when id is valid", %{conn: conn, athlete_profile: athlete_profile} do
      conn = get(conn, Routes.v1_athlete_profile_path(conn, :show, athlete_profile))

      assert %{
               "id" => id,
               "username" => "john_doe",
               "name" => "John Doe",
               "photo" => "https://example.com/photo.jpg",
               "facebook" => "https://www.facebook.com/johndoe",
               "instagram" => "https://www.instagram.com/johndoe",
               "twitter" => "https://www.twitter.com/johndoe"
             } = json_response(conn, 200)["data"]
    end

    test "renders 404 when athlete_profile does not exist", %{conn: conn} do
      assert_error_sent 404, fn ->
        get(conn, Routes.v1_athlete_profile_path(conn, :show, "00000000-0000-0000-0000-000000000000"))
      end
    end
  end

  describe "show_by_username" do
    setup [:create_athlete_profile]

    test "renders athlete_profile when username is valid", %{conn: conn, athlete_profile: athlete_profile} do
      conn = get(conn, Routes.v1_athlete_profile_path(conn, :show_by_username, athlete_profile.username))

      assert %{
               "id" => id,
               "username" => "john_doe",
               "name" => "John Doe"
             } = json_response(conn, 200)["data"]
    end

    test "renders 404 when username does not exist", %{conn: conn} do
      conn = get(conn, Routes.v1_athlete_profile_path(conn, :show_by_username, "nonexistent"))
      assert json_response(conn, 404)["error"] == "Athlete profile not found"
    end
  end

  describe "update athlete_profile" do
    setup [:create_athlete_profile]

    test "renders athlete_profile when data is valid", %{conn: conn, athlete_profile: athlete_profile} do
      conn = put(conn, Routes.v1_athlete_profile_path(conn, :update, athlete_profile), athlete_profile: @update_attrs)
      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.v1_athlete_profile_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "username" => "updated_username",
               "name" => "Updated Name",
               "photo" => "https://example.com/updated_photo.jpg",
               "facebook" => "https://www.facebook.com/updated",
               "instagram" => "https://www.instagram.com/updated",
               "twitter" => "https://www.twitter.com/updated"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, athlete_profile: athlete_profile} do
      conn = put(conn, Routes.v1_athlete_profile_path(conn, :update, athlete_profile), athlete_profile: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete athlete_profile" do
    setup [:create_athlete_profile]

    test "deletes chosen athlete_profile", %{conn: conn, athlete_profile: athlete_profile} do
      conn = delete(conn, Routes.v1_athlete_profile_path(conn, :delete, athlete_profile))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.v1_athlete_profile_path(conn, :show, athlete_profile))
      end
    end
  end

  defp create_athlete_profile(_) do
    athlete_profile = fixture(:athlete_profile)
    %{athlete_profile: athlete_profile}
  end
end
