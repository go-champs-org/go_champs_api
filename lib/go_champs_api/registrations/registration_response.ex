defmodule GoChampsApi.Registrations.RegistrationResponse do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset

  alias GoChampsApi.Registrations.RegistrationInvite

  schema "registration_responses" do
    field :response, :map
    field :status, :string, default: "pending"

    belongs_to :registration_invite, RegistrationInvite

    timestamps()
  end

  @doc false
  def changeset(registration_response, attrs) do
    registration_response
    |> cast(attrs, [:response, :status, :registration_invite_id])
    |> validate_required([:response, :registration_invite_id])
  end
end
