defmodule GoChampsApi.Draws.Draw do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Phases.Phase

  schema "draws" do
    field :title, :string
    field :order, :integer

    embeds_many :matches, Match, on_replace: :delete do
      field :first_team_id, :binary_id
      field :first_team_parent_id, :binary_id
      field :first_team_placeholder, :string
      field :first_team_score, :string

      field :info, :string
      field :name, :string

      field :second_team_id, :binary_id
      field :second_team_parent_id, :binary_id
      field :second_team_placeholder, :string
      field :second_team_score, :string
    end

    belongs_to :phase, Phase

    timestamps()
  end

  @doc false
  def changeset(draw, attrs) do
    draw
    |> cast(attrs, [:order, :title, :phase_id])
    |> cast_embed(:matches, with: &match_changeset/2, required: true)
    |> validate_required([:phase_id])
  end

  defp match_changeset(schema, params) do
    schema
    |> cast(params, [
      :first_team_id,
      :first_team_parent_id,
      :first_team_placeholder,
      :first_team_score,
      :info,
      :name,
      :second_team_id,
      :second_team_parent_id,
      :second_team_placeholder,
      :second_team_score
    ])
  end
end
