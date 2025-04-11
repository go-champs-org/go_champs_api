defmodule GoChampsApi.ScoreboardSettings.ScoreboardSetting do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset

  alias GoChampsApi.Tournaments.Tournament

  schema "scoreboard_settings" do
    field :view, :string, default: "default"
    field :initial_period_time, :integer

    belongs_to :tournament, Tournament

    soft_delete_schema()
    timestamps()
  end

  @doc false
  def changeset(scoreboard_setting, attrs) do
    scoreboard_setting
    |> cast(attrs, [:view, :initial_period_time, :tournament_id])
    |> validate_required([:view, :tournament_id])
  end
end
