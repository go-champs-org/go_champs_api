defmodule GoChampsApi.ScoreboardSettings do
  @moduledoc """
  The ScoreboardSettings context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.ScoreboardSettings.ScoreboardSetting

  @doc """
  Returns the list of scoreboard_settings.

  ## Examples

      iex> list_scoreboard_settings()
      [%ScoreboardSetting{}, ...]

  """
  def list_scoreboard_settings do
    Repo.all(ScoreboardSetting)
  end

  @doc """
  Gets a single scoreboard_setting.

  Raises `Ecto.NoResultsError` if the Scoreboard setting does not exist.

  ## Examples

      iex> get_scoreboard_setting!(123)
      %ScoreboardSetting{}

      iex> get_scoreboard_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scoreboard_setting!(id), do: Repo.get!(ScoreboardSetting, id)

  @doc """
  Gets a scoreboard_setting organization for a given scoreboard_setting id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_scoreboard_setting_organization!(123)
      %Tournament{}

      iex> get_scoreboard_setting_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_scoreboard_setting_organization!(id) do
    {:ok, tournament} =
      Repo.get_by!(ScoreboardSetting, id: id)
      |> Repo.preload(tournament: :organization)
      |> Map.fetch(:tournament)

    {:ok, organization} =
      tournament
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Creates a scoreboard_setting.

  ## Examples

      iex> create_scoreboard_setting(%{field: value})
      {:ok, %ScoreboardSetting{}}

      iex> create_scoreboard_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_scoreboard_setting(attrs \\ %{}) do
    %ScoreboardSetting{}
    |> ScoreboardSetting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a scoreboard_setting.

  ## Examples

      iex> update_scoreboard_setting(scoreboard_setting, %{field: new_value})
      {:ok, %ScoreboardSetting{}}

      iex> update_scoreboard_setting(scoreboard_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_scoreboard_setting(%ScoreboardSetting{} = scoreboard_setting, attrs) do
    scoreboard_setting
    |> ScoreboardSetting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a scoreboard_setting.

  ## Examples

      iex> delete_scoreboard_setting(scoreboard_setting)
      {:ok, %ScoreboardSetting{}}

      iex> delete_scoreboard_setting(scoreboard_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_scoreboard_setting(%ScoreboardSetting{} = scoreboard_setting) do
    Repo.soft_delete(scoreboard_setting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking scoreboard_setting changes.

  ## Examples

      iex> change_scoreboard_setting(scoreboard_setting)
      %Ecto.Changeset{data: %ScoreboardSetting{}}

  """
  def change_scoreboard_setting(%ScoreboardSetting{} = scoreboard_setting, attrs \\ %{}) do
    ScoreboardSetting.changeset(scoreboard_setting, attrs)
  end
end
