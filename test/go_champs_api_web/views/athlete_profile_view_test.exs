defmodule GoChampsApiWeb.AthleteProfileViewTest do
  use GoChampsApiWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  alias GoChampsApi.AthleteProfiles.AthleteProfile

  test "renders index.json" do
    athlete_profiles = [
      %AthleteProfile{
        id: "1",
        username: "john_doe",
        name: "John Doe",
        photo: "https://example.com/photo.jpg",
        facebook: "https://www.facebook.com/johndoe",
        instagram: "https://www.instagram.com/johndoe",
        twitter: "https://www.twitter.com/johndoe",
        inserted_at: ~N[2025-01-01 12:00:00],
        updated_at: ~N[2025-01-01 12:00:00]
      },
      %AthleteProfile{
        id: "2",
        username: "jane_smith",
        name: "Jane Smith",
        photo: "https://example.com/photo2.jpg",
        facebook: "https://www.facebook.com/janesmith",
        instagram: "https://www.instagram.com/janesmith",
        twitter: "https://www.twitter.com/janesmith",
        inserted_at: ~N[2025-01-01 12:00:00],
        updated_at: ~N[2025-01-01 12:00:00]
      }
    ]

    assert render(GoChampsApiWeb.AthleteProfileView, "index.json", %{athlete_profiles: athlete_profiles}) ==
             %{
               data: [
                 %{
                   id: "1",
                   username: "john_doe",
                   name: "John Doe",
                   photo: "https://example.com/photo.jpg",
                   facebook: "https://www.facebook.com/johndoe",
                   instagram: "https://www.instagram.com/johndoe",
                   twitter: "https://www.twitter.com/johndoe",
                   inserted_at: ~N[2025-01-01 12:00:00],
                   updated_at: ~N[2025-01-01 12:00:00]
                 },
                 %{
                   id: "2",
                   username: "jane_smith",
                   name: "Jane Smith",
                   photo: "https://example.com/photo2.jpg",
                   facebook: "https://www.facebook.com/janesmith",
                   instagram: "https://www.instagram.com/janesmith",
                   twitter: "https://www.twitter.com/janesmith",
                   inserted_at: ~N[2025-01-01 12:00:00],
                   updated_at: ~N[2025-01-01 12:00:00]
                 }
               ]
             }
  end

  test "renders show.json" do
    athlete_profile = %AthleteProfile{
      id: "1",
      username: "john_doe",
      name: "John Doe",
      photo: "https://example.com/photo.jpg",
      facebook: "https://www.facebook.com/johndoe",
      instagram: "https://www.instagram.com/johndoe",
      twitter: "https://www.twitter.com/johndoe",
      inserted_at: ~N[2025-01-01 12:00:00],
      updated_at: ~N[2025-01-01 12:00:00]
    }

    assert render(GoChampsApiWeb.AthleteProfileView, "show.json", %{athlete_profile: athlete_profile}) ==
             %{
               data: %{
                 id: "1",
                 username: "john_doe",
                 name: "John Doe",
                 photo: "https://example.com/photo.jpg",
                 facebook: "https://www.facebook.com/johndoe",
                 instagram: "https://www.instagram.com/johndoe",
                 twitter: "https://www.twitter.com/johndoe",
                 inserted_at: ~N[2025-01-01 12:00:00],
                 updated_at: ~N[2025-01-01 12:00:00]
               }
             }
  end
end
