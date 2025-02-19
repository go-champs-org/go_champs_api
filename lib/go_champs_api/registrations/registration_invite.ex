defmodule GoChampsApi.Registrations.RegistrationInvite do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset

  alias GoChampsApi.Registrations.Registration

  schema "registration_invites" do
    field :invitee_id, Ecto.UUID
    field :invitee_type, :string

    belongs_to :registration, Registration

    timestamps()
  end

  @doc false
  def changeset(registration_invite, attrs) do
    registration_invite
    |> cast(attrs, [:invitee_type, :invitee_id, :registration_id])
    |> validate_required([:invitee_type, :invitee_id, :registration_id])
  end
end
