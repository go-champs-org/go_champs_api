defmodule GoChampsApi.Registrations do
  @moduledoc """
  The Registrations context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.Registrations.Registration
  alias GoChampsApi.Tournaments
  alias GoChampsApi.Players
  alias GoChampsApi.Teams

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
      |> Enum.filter(&registration_invite_not_exists?/1)
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
  def get_registration_invite!(id),
    do:
      Repo.get!(RegistrationInvite, id)
      |> may_put_invitee_in_registration_invite()

  @spec registration_invite_not_exists?(%{
          registration_id: Ecto.UUID.t(),
          invitee_id: Ecto.UUID.t(),
          invitee_type: String.t()
        }) :: boolean
  defp registration_invite_not_exists?(%{
         registration_id: registration_id,
         invitee_id: invitee_id,
         invitee_type: invitee_type
       }) do
    query =
      from r in RegistrationInvite,
        where:
          r.registration_id == ^registration_id and r.invitee_id == ^invitee_id and
            r.invitee_type == ^invitee_type

    !Repo.exists?(query)
  end

  @doc """
  Gets a single registration_invite and associated entities.

  Raises `Ecto.NoResultsError` if the Registration invite does not exist.

  ## Examples

    iex> get_registration_invite!(123, [:registration])
    %RegistrationInvite{}

    iex> get_registration_invite!(456, []:registration])
    ** (Ecto.NoResultsError)
  """
  @spec get_registration_invite!(id :: Ecto.UUID.t(), preload :: any()) :: %RegistrationInvite{}
  def get_registration_invite!(id, preload),
    do:
      Repo.get!(RegistrationInvite, id)
      |> Repo.preload(preload)
      |> may_put_invitee_in_registration_invite()

  defp may_put_invitee_in_registration_invite(registration_invite) do
    case registration_invite do
      %RegistrationInvite{} ->
        registration_invite
        |> Map.put(:invitee, get_registration_invite_invitee(registration_invite))

      _ ->
        registration_invite
    end
  end

  @doc """
  Gets the invitee of a registration_invite for a given registration invite.

  Raises `Ecto.NoResultsError` if the Registration invite does not exist.

  ## Examples

      iex> get_registration_invite_invitee(%RegistrationInvite{})
      %Team{}

      iex> get_registration_invite_invitee(%RegistrationInvite{})
      ** (Ecto.NoResultsError)
  """
  @spec get_registration_invite_invitee(%RegistrationInvite{}) :: any()
  def get_registration_invite_invitee(%RegistrationInvite{} = registration_invite) do
    case registration_invite.invitee_type do
      "team" ->
        try do
          Teams.get_team!(registration_invite.invitee_id)
        rescue
          Ecto.NoResultsError -> nil
        end

      _ ->
        nil
    end
  end

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

  @doc """
  Process a registration invite for a give registraion invite id. This logic contains:
  - Loop through all the registration responses for the invitee
  - If the invite is pending, it checks if registration is auto-approve and will process the invite

  ## Examples

      iex> process_registration_invite("some-id")
      :ok
  """
  @spec process_registration_invite(registration_invite_id :: Ecto.UUID.t()) :: :ok
  def process_registration_invite(registration_invite_id) do
    registration_invite =
      Repo.get_by!(RegistrationInvite, id: registration_invite_id)
      |> Repo.preload(:registration)

    registration = registration_invite.registration

    case registration.auto_approve do
      true ->
        registration_invite.id
        |> approve_registration_responses_for_registration_invite()

        :ok

      _ ->
        :ok
    end
  end

  alias GoChampsApi.Registrations.RegistrationResponse

  @doc """
  Returns the list of registration_responses.

  ## Examples

      iex> list_registration_responses()
      [%RegistrationResponse{}, ...]

  """
  def list_registration_responses do
    Repo.all(RegistrationResponse)
  end

  @doc """
  Returns the list of registration_responses for a given where clause.

  ## Examples

      iex> list_registration_responses_where([status: "pending"])
      [%RegistrationResponse{}, ...]
  """
  @spec list_registration_responses(where :: [any()]) :: [%RegistrationResponse{}]
  def list_registration_responses(where) do
    Repo.all(from(r in RegistrationResponse, where: ^where))
  end

  @doc """
  Lists registration responses by registration_invite_id and a property inside the response attribute.

  ## Examples

      iex> list_registration_responses_by_property(registration_response_id, registration_invite_id, "name", "John Doe")
      [%RegistrationResponse{}, ...]

  """
  @spec list_registration_responses_by_property(Ecto.UUID.t(), Ecto.UUID.t(), String.t(), any()) ::
          [
            RegistrationResponse.t()
          ]
  def list_registration_responses_by_property(id, registration_invite_id, property, value) do
    query =
      from(r in RegistrationResponse,
        where:
          r.registration_invite_id == ^registration_invite_id and
            fragment("?->>? = ?", r.response, ^property, ^value)
      )

    query =
      if id do
        from(r in query, where: r.id != ^id)
      else
        query
      end

    Repo.all(query)
  end

  @doc """
  Gets a single registration_response.

  Raises `Ecto.NoResultsError` if the Registration response does not exist.

  ## Examples

      iex> get_registration_response!(123)
      %RegistrationResponse{}

      iex> get_registration_response!(456)
      ** (Ecto.NoResultsError)

  """
  def get_registration_response!(id), do: Repo.get!(RegistrationResponse, id)

  @doc """
  Gets the organization of a registration_response.

  Raises `Ecto.NoResultsError` if the Registration response does not exist.

  ## Examples

      iex> get_registration_response_organization!(123)
      %Organization{}

      iex> get_registration_response_organization!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_registration_response_organization!(id :: Ecto.UUID.t()) :: Organization.t()
  def get_registration_response_organization!(id) do
    registration_response =
      Repo.get_by!(RegistrationResponse, id: id)
      |> Repo.preload(
        registration_invite: [
          registration: [
            tournament: :organization
          ]
        ]
      )

    {:ok, organization} =
      registration_response
      |> Map.fetch!(:registration_invite)
      |> Map.fetch!(:registration)
      |> Map.fetch!(:tournament)
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Creates a registration_response.

  ## Examples

      iex> create_registration_response(%{field: value})
      {:ok, %RegistrationResponse{}}

      iex> create_registration_response(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_registration_response(attrs \\ %{}) do
    case %RegistrationResponse{}
         |> RegistrationResponse.changeset(attrs)
         |> Repo.insert() do
      {:ok, registration_response} ->
        start_registration_response_side_effects(registration_response)

        {:ok, registration_response}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a registration_response.

  ## Examples

      iex> update_registration_response(registration_response, %{field: new_value})
      {:ok, %RegistrationResponse{}}

      iex> update_registration_response(registration_response, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_registration_response(%RegistrationResponse{} = registration_response, attrs) do
    registration_response
    |> RegistrationResponse.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a registration_response.

  ## Examples

      iex> delete_registration_response(registration_response)
      {:ok, %RegistrationResponse{}}

      iex> delete_registration_response(registration_response)
      {:error, %Ecto.Changeset{}}

  """
  def delete_registration_response(%RegistrationResponse{} = registration_response) do
    Repo.delete(registration_response)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking registration_response changes.

  ## Examples

      iex> change_registration_response(registration_response)
      %Ecto.Changeset{data: %RegistrationResponse{}}

  """
  def change_registration_response(%RegistrationResponse{} = registration_response, attrs \\ %{}) do
    RegistrationResponse.changeset(registration_response, attrs)
  end

  @doc """
  Start side effects for a creation of a registration_response.

  ## Examples

      iex> start_registration_response_side_effects(%RegistrationResponse{})
      :ok
  """
  @spec start_registration_response_side_effects(RegistrationResponse.t()) :: :ok
  def start_registration_response_side_effects(
        %RegistrationResponse{registration_invite_id: registration_invite_id} =
          _registration_response
      ) do
    %{registration_invite_id: registration_invite_id}
    |> GoChampsApi.Infrastructure.Jobs.ProcessRegistrationInvite.new()
    |> Oban.insert()

    :ok
  end

  @doc """
  Approve registration responses for a given registration invite id.

  ## Examples

      iex> approve_registration_responses_for_registration_invite(registration_invite_id)
      :ok
  """
  @spec approve_registration_responses_for_registration_invite(
          registration_invite_id :: Ecto.UUID.t()
        ) :: :ok
  def approve_registration_responses_for_registration_invite(registration_invite_id) do
    registration_invite =
      Repo.get_by!(RegistrationInvite, id: registration_invite_id)
      |> Repo.preload([:registration, :registration_responses])

    case registration_invite.registration.type do
      "team_roster_invites" ->
        Enum.filter(registration_invite.registration_responses, fn response ->
          response.status == "pending"
        end)
        |> Enum.map(&approve_team_roster_response/1)

      _ ->
        :ok
    end
  end

  @doc """
  Approve team roster response for a given registration response.

  ## Examples

      iex> approve_team_roster_response(registration_response)
      :ok
  """
  @spec approve_team_roster_response(RegistrationResponse.t()) :: :ok
  def approve_team_roster_response(%RegistrationResponse{} = registration_response) do
    case registration_response.status do
      "pending" ->
        registration_response
        |> preload_registration_invite()
        |> create_player_from_response()
        |> handle_player_creation_result()

      _ ->
        :ok
    end
  end

  defp preload_registration_invite(registration_response) do
    Repo.preload(registration_response, registration_invite: :registration)
  end

  defp create_player_from_response(%RegistrationResponse{} = registration_response) do
    player_attrs = %{
      tournament_id: registration_response.registration_invite.registration.tournament_id,
      team_id: registration_response.registration_invite.invitee_id,
      name: registration_response.response["name"],
      shirt_number: registration_response.response["shirt_number"],
      shirt_name: registration_response.response["shirt_name"],
      registration_response_id: registration_response.id
    }

    {Players.create_player(player_attrs), registration_response}
  end

  defp handle_player_creation_result({{:ok, _player}, registration_response}) do
    update_registration_response(registration_response, %{status: "approved"})
  end

  defp handle_player_creation_result({{:error, _error}, _registration_response}) do
    :error
  end
end
