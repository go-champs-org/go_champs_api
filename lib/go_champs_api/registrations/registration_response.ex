defmodule GoChampsApi.Registrations.RegistrationResponse do
  use Ecto.Schema
  use GoChampsApi.Schema
  import Ecto.Changeset

  alias GoChampsApi.Registrations.RegistrationInvite
  alias GoChampsApi.Registrations

  schema "registration_responses" do
    field :response, :map
    field :status, :string, default: "pending"

    belongs_to :registration_invite, RegistrationInvite

    soft_delete_schema()
    timestamps()
  end

  @doc false
  def changeset(registration_response, attrs) do
    registration_response
    |> cast(attrs, [:response, :status, :registration_invite_id])
    |> validate_required([:response, :registration_invite_id])
    |> merge_response(registration_response)
    |> validate_response()
    |> validate_active_registration()
  end

  defp merge_response(changeset, registration_response) do
    response = get_field(changeset, :response)

    case registration_response.response do
      nil ->
        changeset

      _ ->
        changeset
        |> put_change(:response, Map.merge(registration_response.response, response))
    end
  end

  defp validate_response(changeset) do
    registration_invite_id = get_field(changeset, :registration_invite_id)

    registration_invite =
      Registrations.get_registration_invite!(registration_invite_id, [:registration])

    case registration_invite.registration.type do
      "team_roster_invites" ->
        changeset
        |> validate_required_response_fields(["name", "email"])
        |> validate_unique_email(registration_invite)

      _ ->
        changeset
    end
  end

  defp validate_required_response_fields(changeset, fields) do
    response = get_field(changeset, :response)

    case response do
      nil ->
        changeset

      _ ->
        case Enum.all?(fields, fn field ->
               Map.has_key?(response, field) && not is_nil(response[field]) &&
                 response[field] != ""
             end) do
          true ->
            changeset

          false ->
            add_error(changeset, :response, "missing required fields")
        end
    end
  end

  defp validate_unique_email(changeset, registration_invite) do
    case get_field(changeset, :response) do
      nil ->
        changeset

      response ->
        id = get_field(changeset, :id)
        new_email = Map.get(response, "email")

        case Registrations.list_registration_responses_by_property(
               id,
               registration_invite.id,
               "email",
               new_email
             ) do
          [] ->
            changeset

          _ ->
            add_error(changeset, :response, "email already exists")
        end
    end
  end

  defp validate_active_registration(changeset) do
    registration_invite_id = get_field(changeset, :registration_invite_id)

    registration_invite =
      Registrations.get_registration_invite!(registration_invite_id, [:registration])

    case {registration_invite.registration.start_date, registration_invite.registration.end_date} do
      {nil, nil} ->
        changeset

      {start_date, end_date} ->
        case Date.compare(Date.utc_today(), start_date) do
          :lt ->
            add_error(changeset, :registration_invite_id, "registration is not active yet")

          _ ->
            case Date.compare(Date.utc_today(), end_date) do
              :gt ->
                add_error(
                  changeset,
                  :registration_invite_id,
                  "registration is not active anymore"
                )

              _ ->
                changeset
            end
        end
    end
  end
end
