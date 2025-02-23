defmodule GoChampsApi.Helpers.RegistrationHelpers do
  alias GoChampsApi.Registrations
  alias GoChampsApi.Helpers.TournamentHelpers

  @valid_registration_attrs %{
    auto_approve: true,
    end_date: "2010-04-17T14:00:00Z",
    start_date: "2010-04-17T14:00:00Z",
    title: "some title",
    type: "team_roster_invites"
  }

  @valid_registration_invite_attrs %{
    invitee_id: Ecto.UUID.autogenerate(),
    invitee_type: "team"
  }

  def map_registration_id_in_attrs(attrs \\ %{}) do
    {:ok, registration} =
      @valid_registration_attrs
      |> create_or_use_tournament_id(attrs)
      |> Registrations.create_registration()

    Map.merge(attrs, %{registration_id: registration.id})
  end

  def map_registration_id_with_other_member(attrs \\ %{}) do
    {:ok, registration} =
      @valid_registration_attrs
      |> TournamentHelpers.map_tournament_id_with_other_member()
      |> Registrations.create_registration()

    Map.merge(attrs, %{registration_id: registration.id})
  end

  defp create_or_use_tournament_id(registration_attrs, additional_attrs) do
    case Map.fetch(additional_attrs, :tournament_id) do
      {:ok, tournament_id} ->
        Map.merge(registration_attrs, %{tournament_id: tournament_id})

      :error ->
        registration_attrs
        |> TournamentHelpers.map_tournament_id()
    end
  end

  def map_registration_invite_id_in_attrs(attrs \\ %{}) do
    {:ok, registration_invite} =
      @valid_registration_invite_attrs
      |> map_registration_id_in_attrs()
      |> Registrations.create_registration_invite()

    Map.merge(attrs, %{registration_invite_id: registration_invite.id})
  end

  def create_registration(attrs \\ %{}) do
    {:ok, registration} =
      @valid_registration_attrs
      |> create_or_use_tournament_id(attrs)
      |> Registrations.create_registration()

    registration
  end

  def create_registration_invite(attrs \\ %{}) do
    {:ok, registration_invite} =
      @valid_registration_invite_attrs
      |> create_or_use_registration_id(attrs)
      |> Registrations.create_registration_invite()

    registration_invite
  end

  defp create_or_use_registration_id(registration_invite_attrs, additional_attrs) do
    case Map.fetch(additional_attrs, :registration_id) do
      {:ok, registration_id} ->
        Map.merge(registration_invite_attrs, %{registration_id: registration_id})

      :error ->
        registration_invite_attrs
        |> map_registration_id_in_attrs()
    end
  end
end
