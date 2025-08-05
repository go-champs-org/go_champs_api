defmodule GoChampsApiWeb.AthleteProfileController do
  use GoChampsApiWeb, :controller

  alias GoChampsApi.AthleteProfiles
  alias GoChampsApi.AthleteProfiles.AthleteProfile

  action_fallback GoChampsApiWeb.FallbackController

  def index(conn, _params) do
    athlete_profiles = AthleteProfiles.list_athlete_profiles()
    render(conn, "index.json", athlete_profiles: athlete_profiles)
  end

  def create(conn, %{"athlete_profile" => athlete_profile_params}) do
    with {:ok, %AthleteProfile{} = athlete_profile} <- AthleteProfiles.create_athlete_profile(athlete_profile_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.v1_athlete_profile_path(conn, :show, athlete_profile))
      |> render("show.json", athlete_profile: athlete_profile)
    end
  end

  def show(conn, %{"id" => id}) do
    athlete_profile = AthleteProfiles.get_athlete_profile!(id)
    render(conn, "show.json", athlete_profile: athlete_profile)
  end

  def show_by_username(conn, %{"username" => username}) do
    case AthleteProfiles.get_athlete_profile_by_username(username) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Athlete profile not found"})
      athlete_profile ->
        render(conn, "show.json", athlete_profile: athlete_profile)
    end
  end

  def update(conn, %{"id" => id, "athlete_profile" => athlete_profile_params}) do
    athlete_profile = AthleteProfiles.get_athlete_profile!(id)

    with {:ok, %AthleteProfile{} = athlete_profile} <- AthleteProfiles.update_athlete_profile(athlete_profile, athlete_profile_params) do
      render(conn, "show.json", athlete_profile: athlete_profile)
    end
  end

  def delete(conn, %{"id" => id}) do
    athlete_profile = AthleteProfiles.get_athlete_profile!(id)

    with {:ok, %AthleteProfile{}} <- AthleteProfiles.delete_athlete_profile(athlete_profile) do
      send_resp(conn, :no_content, "")
    end
  end
end
