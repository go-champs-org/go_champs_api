defmodule GoChampsApiWeb.AthleteProfileView do
  use GoChampsApiWeb, :view
  alias GoChampsApiWeb.AthleteProfileView

  def render("index.json", %{athlete_profiles: athlete_profiles}) do
    %{data: render_many(athlete_profiles, AthleteProfileView, "athlete_profile.json")}
  end

  def render("show.json", %{athlete_profile: athlete_profile}) do
    %{data: render_one(athlete_profile, AthleteProfileView, "athlete_profile.json")}
  end

  def render("athlete_profile.json", %{athlete_profile: athlete_profile}) do
    %{
      id: athlete_profile.id,
      username: athlete_profile.username,
      name: athlete_profile.name,
      photo: athlete_profile.photo,
      facebook: athlete_profile.facebook,
      instagram: athlete_profile.instagram,
      twitter: athlete_profile.twitter,
      inserted_at: athlete_profile.inserted_at,
      updated_at: athlete_profile.updated_at
    }
  end
end
