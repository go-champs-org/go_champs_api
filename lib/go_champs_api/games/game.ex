defmodule GoChampsApi.Games.Game do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Phases.Phase
  alias GoChampsApi.Teams.Team

  schema "games" do
    field :away_score, :integer
    field :away_placeholder, :string
    field :datetime, :utc_datetime
    field :home_score, :integer
    field :home_placeholder, :string
    field :info, :string
    field :is_finished, :boolean
    field :location, :string
    field :live_state, Ecto.Enum, values: [:not_started, :in_progress, :ended]
    field :live_started_at, :utc_datetime
    field :live_ended_at, :utc_datetime
    field :youtube_code, :string

    belongs_to :phase, Phase
    belongs_to :away_team, Team
    belongs_to :home_team, Team

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [
      :datetime,
      :location,
      :away_score,
      :away_placeholder,
      :home_score,
      :home_placeholder,
      :phase_id,
      :info,
      :is_finished,
      :live_state,
      :live_started_at,
      :live_ended_at,
      :away_team_id,
      :home_team_id,
      :youtube_code
    ])
    |> validate_required([:phase_id])
    |> validate_inclusion(:live_state, [:not_started, :in_progress, :ended])
    |> restrict_changes_if_in_progress(game)
    |> update_fields_related_to_is_finished()
    |> update_fields_related_to_live_state()
  end

  defp restrict_changes_if_in_progress(changeset, game) do
    if game.live_state == :in_progress do
      changeset
      |> validate_no_changes_except_live_state()
    else
      changeset
    end
  end

  defp update_fields_related_to_is_finished(changeset) do
    case get_change(changeset, :is_finished) do
      true ->
        changeset
        |> put_change(
          :live_state,
          :ended
        )

      false ->
        changeset
        |> put_change(
          :live_state,
          :not_started
        )
        |> put_change(:live_ended_at, nil)

      _ ->
        changeset
    end
  end

  defp validate_no_changes_except_live_state(changeset) do
    allowed_fields = [:live_state]
    changes = changeset.changes |> Map.keys()

    changes
    |> Enum.reject(&(&1 in allowed_fields))
    |> Enum.reduce(changeset, fn field, acc ->
      add_error(acc, field, "cannot be changed while game is in progress")
    end)
  end

  defp update_fields_related_to_live_state(changeset) do
    case get_field(changeset, :live_state) do
      :in_progress ->
        changeset
        |> put_change(
          :live_started_at,
          DateTime.utc_now()
          |> DateTime.truncate(:second)
        )

      :ended ->
        changeset
        |> put_change(:is_finished, true)
        |> put_change(
          :live_ended_at,
          DateTime.utc_now()
          |> DateTime.truncate(:second)
        )

      _ ->
        changeset
    end
  end
end
