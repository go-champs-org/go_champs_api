defmodule GoChampsApi.Registrations do
  @moduledoc """
  The Registrations context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.Registrations.Registration
  alias GoChampsApi.Tournaments

  @doc """
  Returns the list of registrations.

  ## Examples

      iex> list_registrations()
      [%Registration{}, ...]

  """
  def list_registrations do
    Repo.all(Registration)
  end

  @doc """
  Gets a single registration.

  Raises `Ecto.NoResultsError` if the Registration does not exist.

  ## Examples

      iex> get_registration!(123)
      %Registration{}

      iex> get_registration!(456)
      ** (Ecto.NoResultsError)

  """
  def get_registration!(id),
    do: Repo.get!(Registration, id) |> Repo.preload(:registration_invites)

  @doc """
  Gets the organization of a registration.

  Raises `Ecto.NoResultsError` if the Registration does not exist.

  ## Examples

      iex> get_registration_organization!(123)
      %Organization{}

      iex> get_registration_organization!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_registration_organization!(id :: Ecto.UUID.t()) :: Organization.t()
  def get_registration_organization!(id) do
    {:ok, tournament} =
      Repo.get_by!(Registration, id: id)
      |> Repo.preload(tournament: :organization)
      |> Map.fetch(:tournament)

    {:ok, organization} =
      tournament
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Creates a registration.

  ## Examples

      iex> create_registration(%{field: value})
      {:ok, %Registration{}}

      iex> create_registration(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration(attrs \\ %{}) do
    %Registration{}
    |> Registration.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a registration.

  ## Examples

      iex> update_registration(registration, %{field: new_value})
      {:ok, %Registration{}}

      iex> update_registration(registration, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration(%Registration{} = registration, attrs) do
    registration
    |> Registration.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a registration.

  ## Examples

      iex> delete_registration(registration)
      {:ok, %Registration{}}

      iex> delete_registration(registration)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registration(%Registration{} = registration) do
    Repo.delete(registration)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration changes.

  ## Examples

      iex> change_registration(registration)
      %Ecto.Changeset{data: %Registration{}}

  """
  def change_registration(%Registration{} = registration, attrs \\ %{}) do
    Registration.changeset(registration, attrs)
  end

  @doc """
  Generate registration invites for a given registration id.

  ## Examples

      iex> generate_registration_invites(registration_id)
      {:ok, [%RegistrationInvite{}]}

  """
  @spec generate_registration_invites(registration_id :: Ecto.UUID.t()) ::
          {:ok, [RegistrationInvite.t()]}
  def generate_registration_invites(registration_id) do
    registration = get_registration!(registration_id)

    case registration.type do
      "team_roster_invites" ->
        registration
        |> generate_team_roster_invites()

      _ ->
        {:error, "Unsupported registration type"}
    end
  end

  @doc """
  Generate team roster invites for a given registration.

  ## Examples

      iex> generate_team_roster_invites(registration)
      {:ok, [%RegistrationInvite{}]}

  """
  @spec generate_team_roster_invites(Registration.t()) :: {:ok, [RegistrationInvite.t()]}
  def generate_team_roster_invites(registration) do
    teams =
      Tournaments.get_tournament!(registration.tournament_id)
      |> Map.fetch!(:teams)

    batch_result =
      teams
      |> Enum.map(fn team ->
        %{
          registration_id: registration.id,
          invitee_id: team.id,
          invitee_type: "team"
        }
      end)
      |> Enum.map(&create_registration_invite/1)

    case Enum.find(batch_result, fn
           {:error, _} -> true
           _ -> false
         end) do
      nil ->
        {:ok, Enum.map(batch_result, &elem(&1, 1))}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  alias GoChampsApi.Registrations.RegistrationInvite

  @doc """
  Returns the list of registration_invites.

  ## Examples

      iex> list_registration_invites()
      [%RegistrationInvite{}, ...]

  """
  def list_registration_invites do
    Repo.all(RegistrationInvite)
  end

  @doc """
  Gets a single registration_invite.

  Raises `Ecto.NoResultsError` if the Registration invite does not exist.

  ## Examples

      iex> get_registration_invite!(123)
      %RegistrationInvite{}

      iex> get_registration_invite!(456)
      ** (Ecto.NoResultsError)

  """
  def get_registration_invite!(id), do: Repo.get!(RegistrationInvite, id)

  @doc """
  Creates a registration_invite.

  ## Examples

      iex> create_registration_invite(%{field: value})
      {:ok, %RegistrationInvite{}}

      iex> create_registration_invite(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration_invite(attrs \\ %{}) do
    %RegistrationInvite{}
    |> RegistrationInvite.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a registration_invite.

  ## Examples

      iex> update_registration_invite(registration_invite, %{field: new_value})
      {:ok, %RegistrationInvite{}}

      iex> update_registration_invite(registration_invite, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration_invite(%RegistrationInvite{} = registration_invite, attrs) do
    registration_invite
    |> RegistrationInvite.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a registration_invite.

  ## Examples

      iex> delete_registration_invite(registration_invite)
      {:ok, %RegistrationInvite{}}

      iex> delete_registration_invite(registration_invite)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registration_invite(%RegistrationInvite{} = registration_invite) do
    Repo.delete(registration_invite)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration_invite changes.

  ## Examples

      iex> change_registration_invite(registration_invite)
      %Ecto.Changeset{data: %RegistrationInvite{}}

  """
  def change_registration_invite(%RegistrationInvite{} = registration_invite, attrs \\ %{}) do
    RegistrationInvite.changeset(registration_invite, attrs)
  end
end
