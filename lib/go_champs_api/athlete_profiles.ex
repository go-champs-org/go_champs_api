defmodule GoChampsApi.AthleteProfiles do
  @moduledoc """
  The AthleteProfiles context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.AthleteProfiles.AthleteProfile

  @doc """
  Returns the list of athlete_profiles.

  ## Examples

      iex> list_athlete_profiles()
      [%AthleteProfile{}, ...]

  """
  def list_athlete_profiles do
    Repo.all(AthleteProfile)
  end

  @doc """
  Gets a single athlete_profile.

  Raises `Ecto.NoResultsError` if the Athlete profile does not exist.

  ## Examples

      iex> get_athlete_profile!(123)
      %AthleteProfile{}

      iex> get_athlete_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_athlete_profile!(id), do: Repo.get!(AthleteProfile, id)

  @doc """
  Gets a single athlete_profile by username.

  Returns `nil` if the Athlete profile does not exist.

  ## Examples

      iex> get_athlete_profile_by_username("john_doe")
      %AthleteProfile{}

      iex> get_athlete_profile_by_username("nonexistent")
      nil

  """
  def get_athlete_profile_by_username(username) do
    Repo.get_by(AthleteProfile, username: username)
  end

  @doc """
  Creates a athlete_profile.

  ## Examples

      iex> create_athlete_profile(%{field: value})
      {:ok, %AthleteProfile{}}

      iex> create_athlete_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_athlete_profile(attrs \\ %{}) do
    %AthleteProfile{}
    |> AthleteProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a athlete_profile.

  ## Examples

      iex> update_athlete_profile(athlete_profile, %{field: new_value})
      {:ok, %AthleteProfile{}}

      iex> update_athlete_profile(athlete_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_athlete_profile(%AthleteProfile{} = athlete_profile, attrs) do
    athlete_profile
    |> AthleteProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a athlete_profile.

  ## Examples

      iex> delete_athlete_profile(athlete_profile)
      {:ok, %AthleteProfile{}}

      iex> delete_athlete_profile(athlete_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_athlete_profile(%AthleteProfile{} = athlete_profile) do
    Repo.delete(athlete_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking athlete_profile changes.

  ## Examples

      iex> change_athlete_profile(athlete_profile)
      %Ecto.Changeset{data: %AthleteProfile{}}

  """
  def change_athlete_profile(%AthleteProfile{} = athlete_profile, attrs \\ %{}) do
    AthleteProfile.changeset(athlete_profile, attrs)
  end
end
