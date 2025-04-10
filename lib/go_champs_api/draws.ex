defmodule GoChampsApi.Draws do
  @moduledoc """
  The Draws context.
  """

  import Ecto.Query, warn: false
  alias GoChampsApi.Repo

  alias GoChampsApi.Draws.Draw
  alias GoChampsApi.Phases

  @doc """
  Gets a single draw.

  Raises `Ecto.NoResultsError` if the Draw does not exist.

  ## Examples

      iex> get_draw!(123)
      %Draw{}

      iex> get_draw!(456)
      ** (Ecto.NoResultsError)

  """
  def get_draw!(id), do: Repo.get!(Draw, id)

  def get_draw_organization!(id) do
    {:ok, phase} =
      Repo.get!(Draw, id)
      |> Repo.preload([:phase])
      |> Map.fetch(:phase)

    Phases.get_phase_organization!(phase.id)
  end

  @doc """
  Gets a draws phase id.

  Raises `Ecto.NoResultsError` if the Tournament does not exist.

  ## Examples

  iex> get_draws_phase_id!(123)
  %Tournament{}

  iex> get_draws_phase_id!(456)
  ** (Ecto.NoResultsError)

  """
  def get_draws_phase_id(draws) do
    draws_id = Enum.map(draws, fn draw -> draw["id"] end)

    case Repo.all(
           from draw in Draw,
             where: draw.id in ^draws_id,
             group_by: draw.phase_id,
             select: draw.phase_id
         ) do
      [phase_id] ->
        {:ok, phase_id}

      _ ->
        {:error, "Can only update draw from same phase"}
    end
  end

  @doc """
  Creates a draw.

  ## Examples

      iex> create_draw(%{field: value})
      {:ok, %Draw{}}

      iex> create_draw(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_draw(attrs \\ %{}) do
    %Draw{}
    |> Draw.changeset(attrs)
    |> get_draw_next_order()
    |> Repo.insert()
  end

  defp get_draw_next_order(changeset) do
    phase_id = Ecto.Changeset.get_field(changeset, :phase_id)

    if phase_id do
      number_of_records =
        Draw
        |> where([s], s.phase_id == ^phase_id)
        |> Repo.aggregate(:count, :id)

      Ecto.Changeset.put_change(changeset, :order, Enum.sum([number_of_records, 1]))
    else
      changeset
    end
  end

  @doc """
  Updates a draw.

  ## Examples

      iex> update_draw(draw, %{field: new_value})
      {:ok, %Draw{}}

      iex> update_draw(draw, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_draw(%Draw{} = draw, attrs) do
    draw
    |> Draw.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates many draws.

  ## Examples

      iex> update_draws([%{field: new_value}])
      {:ok, [%Phase{}]}

      iex> update_draws([%{field: bad_value}])
      {:error, %Ecto.Changeset{}}

  """
  def update_draws(draws) do
    multi =
      draws
      |> Enum.reduce(Ecto.Multi.new(), fn draw, multi ->
        %{"id" => id} = draw
        current_draw = Repo.get_by!(Draw, id: id)
        changeset = Draw.changeset(current_draw, draw)

        Ecto.Multi.update(multi, id, changeset)
      end)

    Repo.transaction(multi)
  end

  @doc """
  Deletes a Draw.

  ## Examples

      iex> delete_draw(draw)
      {:ok, %Draw{}}

      iex> delete_draw(draw)
      {:error, %Ecto.Changeset{}}

  """
  def delete_draw(%Draw{} = draw) do
    Repo.delete(draw)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking draw changes.

  ## Examples

      iex> change_draw(draw)
      %Ecto.Changeset{source: %Draw{}}

  """
  def change_draw(%Draw{} = draw) do
    Draw.changeset(draw, %{})
  end

  @doc """
  Update draws matches from team head to head stats for a give draw id.

  ## Examples

      iex> update_matches_from_aggregated_team_head_to_head_stats_by_phase(draw_id)
      {:ok, %Draw{}}

      iex> update_matches_from_aggregated_team_head_to_head_stats_by_phase(draw_id)
      {:error, %Ecto.Changeset{}}

  """
  def update_matches_from_aggregated_team_head_to_head_stats_by_phase(draw_id) do
    draw = Repo.get!(Draw, draw_id)

    # Enum.each(draw.matches, fn match ->
    #   Sports.update_match_result(match.id)
    # end)

    {:ok, draw}
  end
end
