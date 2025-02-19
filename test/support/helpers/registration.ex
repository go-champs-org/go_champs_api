defmodule GoChampsApi.Helpers.RegistrationHelpers do
  alias GoChampsApi.Registrations
  alias GoChampsApi.Helpers.TournamentHelpers

  @valid_attrs %{
    auto_approve: true,
    end_date: "2010-04-17T14:00:00Z",
    start_date: "2010-04-17T14:00:00Z",
    title: "some title",
    type: "some type"
  }

  def map_registration_id_in_attrs(attrs \\ %{}) do
    {:ok, registration} =
      @valid_attrs
      |> create_or_use_tournament_id(attrs)
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
end
