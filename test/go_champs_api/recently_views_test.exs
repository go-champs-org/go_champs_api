defmodule GoChampsApi.RecentlyViewsTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.Helpers.TournamentHelpers
  alias GoChampsApi.Organizations
  alias GoChampsApi.RecentlyViews
  alias GoChampsApi.Tournaments

  describe "recently_view" do
    alias GoChampsApi.RecentlyViews.RecentlyView

    @valid_attrs %{}
    @invalid_attrs %{}

    def recently_view_fixture(attrs \\ %{}) do
      {:ok, recently_view} =
        attrs
        |> Enum.into(@valid_attrs)
        |> TournamentHelpers.map_tournament_id()
        |> RecentlyViews.create_recently_view()

      recently_view
    end

    def recently_view_for_tournament_id(tournament_id) do
      {:ok, recently_view} =
        @valid_attrs
        |> Map.merge(%{tournament_id: tournament_id})
        |> RecentlyViews.create_recently_view()

      recently_view
    end

    def recently_view_for_other_tournament(attrs \\ %{}) do
      {:ok, organization} =
        Organizations.create_organization(%{name: "another organization", slug: "another-slug"})

      {:ok, tournament} =
        %{name: "another name", slug: "some-slug"}
        |> Map.merge(%{organization_id: organization.id})
        |> Tournaments.create_tournament()

      {:ok, recently_view} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.merge(%{tournament_id: tournament.id})
        |> RecentlyViews.create_recently_view()

      recently_view
    end

    test "list_recently_view/0 returns one recently_view aggegated by tournament_id with count" do
      recently_view = recently_view_fixture()

      [recently_view_result] = RecentlyViews.list_recently_view()
      assert recently_view_result.tournament_id == recently_view.tournament_id
      assert recently_view_result.views == 1
      assert recently_view_result.tournament.id == recently_view.tournament_id
    end

    test "list_recently_view/0 returns recently_views aggegated by tournament_id with count" do
      first_recently_view = recently_view_fixture()
      _second_recently_view = recently_view_for_tournament_id(first_recently_view.tournament_id)
      third_recently_view = recently_view_for_other_tournament()

      [first_tournament, second_tournament] = RecentlyViews.list_recently_view()

      assert first_tournament.tournament_id == first_recently_view.tournament_id
      assert first_tournament.views == 2
      assert first_tournament.tournament.id == first_recently_view.tournament_id
      assert second_tournament.tournament_id == third_recently_view.tournament_id
      assert second_tournament.views == 1
      assert second_tournament.tournament.id == third_recently_view.tournament_id
    end

    test "get_recently_view!/1 returns the recently_view with given id" do
      recently_view = recently_view_fixture()
      assert RecentlyViews.get_recently_view!(recently_view.id) == recently_view
    end

    test "create_recently_view/1 with valid data creates a recently_view" do
      valid_attrs = TournamentHelpers.map_tournament_id(@valid_attrs)

      assert {:ok, %RecentlyView{} = _recently_view} =
               RecentlyViews.create_recently_view(valid_attrs)
    end

    test "create_recently_view/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RecentlyViews.create_recently_view(@invalid_attrs)
    end

    test "change_recently_view/1 returns a recently_view changeset" do
      recently_view = recently_view_fixture()
      assert %Ecto.Changeset{} = RecentlyViews.change_recently_view(recently_view)
    end
  end
end
