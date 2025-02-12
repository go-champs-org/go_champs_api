defmodule GoChampsApi.Phases do
  @moduledoc """
  The Phases context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.Phases.Phase

  @doc """
  Gets a single phase.

  Raises `Ecto.NoResultsError` if the Tournament phase does not exist.

  ## Examples

      iex> get_phase!(123)
      %Phase{}

      iex> get_phase!(456)
      ** (Ecto.NoResultsError)

  """
  def get_phase!(id),
    do:
      Repo.get_by!(Phase, id: id)
      |> Repo.preload([:tournament, :draws, :eliminations])

  @doc """
  Gets a phase organization for a given phase id..

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

      iex> get_phase_organization!(123)
      %Tournament{}

      iex> get_phase_organization!(456)
      ** (Ecto.NoResultsError)

  """
  def get_phase_organization!(id) do
    {:ok, tournament} =
      Repo.get_by!(Phase, id: id)
      |> Repo.preload(tournament: :organization)
      |> Map.fetch(:tournament)

    {:ok, organization} =
      tournament
      |> Map.fetch(:organization)

    organization
  end

  @doc """
  Gets a phases tournament id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

  iex> get_phases_tournament_id!(123)
  %Tournament{}

  iex> get_phases_tournament_id!(456)
  ** (Ecto.NoResultsError)

  """
  def get_phases_tournament_id(phases) do
    phases_id = Enum.map(phases, fn phase -> phase["id"] end)

    case Repo.all(
           from phase in Phase,
             where: phase.id in ^phases_id,
             group_by: phase.tournament_id,
             select: phase.tournament_id
         ) do
      [tournament_id] ->
        {:ok, tournament_id}

      _ ->
        {:error, "Can only update phase from same tournament"}
    end
  end

  @doc """
  Creates a phase.

  ## Examples

      iex> create_phase(%{field: value})
      {:ok, %Phase{}}

      iex> create_phase(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_phase(attrs \\ %{}) do
    %Phase{}
    |> Phase.changeset(attrs)
    |> get_phase_next_order()
    |> Repo.insert()
  end

  defp get_phase_next_order(changeset) do
    tournament_id = Ecto.Changeset.get_field(changeset, :tournament_id)

    query =
      if tournament_id do
        from p in Phase, where: p.tournament_id == ^tournament_id
      else
        from(p in Phase)
      end

    number_of_records = Repo.aggregate(query, :count, :id)
    Ecto.Changeset.put_change(changeset, :order, Enum.sum([number_of_records, 1]))
  end

  @doc """
  Updates a phase.

  ## Examples

      iex> update_phase(phase, %{field: new_value})
      {:ok, %Phase{}}

      iex> update_phase(phase, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_phase(%Phase{} = phase, attrs) do
    phase
    |> Phase.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates many phases.

  ## Examples

      iex> update_phase([%{field: new_value}])
      {:ok, [%Phase{}]}

      iex> update_phase([%{field: bad_value}])
      {:error, %Ecto.Changeset{}}

  """
  def update_phases(phases) do
    multi =
      phases
      |> Enum.reduce(Ecto.Multi.new(), fn phase, multi ->
        %{"id" => id} = phase
        current_phase = Repo.get_by!(Phase, id: id)
        changeset = Phase.changeset(current_phase, phase)

        Ecto.Multi.update(multi, id, changeset)
      end)

    Repo.transaction(multi)
  end

  @doc """
  Deletes a Phase.

  ## Examples

      iex> delete_phase(phase)
      {:ok, %Phase{}}

      iex> delete_phase(phase)
      {:error, %Ecto.Changeset{}}

  """
  def delete_phase(%Phase{} = phase) do
    Repo.delete(phase)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking phase changes.

  ## Examples

      iex> change_phase(phase)
      %Ecto.Changeset{source: %Phase{}}

  """
  def change_phase(%Phase{} = phase) do
    Phase.changeset(phase, %{})
  end

  @doc """
  Generate phase results for a given phase id that would include:
  1. Team stadings;
  2. Bracket results;

  And returns `:ok` if the operation was successful or `:error` if it failed.

  ## Examples

      iex> generate_phase_results("phase-id")
      :ok
  """
  @spec generate_phase_results(phase_id :: Ecto.UUID.t()) :: :ok | :error
  def generate_phase_results(phase_id) do
    phase = get_phase!(phase_id)

    case phase.type do
      "elimination" ->
        :ok

      _ ->
        :error
    end
  end
end
