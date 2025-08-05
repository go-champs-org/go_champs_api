defmodule GoChampsApi.AthleteProfiles.AthleteProfile do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset

  schema "athlete_profiles" do
    field :username, :string
    field :name, :string
    field :photo, :string
    field :facebook, :string
    field :instagram, :string
    field :twitter, :string

    timestamps()
  end

  @doc false
  def changeset(athlete_profile, attrs) do
    athlete_profile
    |> cast(attrs, [:username, :name, :photo, :facebook, :instagram, :twitter])
    |> validate_required([:username, :name])
    |> unique_constraint(:username)
  end
end
