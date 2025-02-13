defmodule GoChampsApi.Eliminations.Elimination do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Phases.Phase

  schema "eliminations" do
    field :title, :string
    field :info, :string
    field :order, :integer

    embeds_many :team_stats, TeamStats, on_replace: :delete do
      field :placeholder, :string
      field :team_id, :binary_id
      field :stats, :map
    end

    belongs_to :phase, Phase

    timestamps()
  end

  @doc false
  def changeset(elimination, attrs) do
    elimination
    |> cast(attrs, [:title, :info, :order, :phase_id])
    |> cast_embed(:team_stats, with: &team_stats_changeset/2, required: true)
    |> validate_required([:phase_id])
  end

  defp team_stats_changeset(schema, params) do
    schema
    |> cast(params, [:placeholder, :stats, :team_id])
  end
end

defmodule GoChampsApi.Eliminations.TeamStats do
  defstruct [:placeholder, :team_id, :stats]
end
