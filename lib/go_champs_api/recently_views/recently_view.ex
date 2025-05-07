defmodule GoChampsApi.RecentlyViews.RecentlyView do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset
  alias GoChampsApi.Tournaments.Tournament

  schema "recently_view" do
    belongs_to :tournament, Tournament

    soft_delete_schema()
    timestamps()
  end

  @doc false
  def changeset(recently_view, attrs) do
    recently_view
    |> cast(attrs, [:tournament_id])
    |> validate_required([:tournament_id])
  end
end
