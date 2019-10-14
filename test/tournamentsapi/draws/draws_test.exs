defmodule TournamentsApi.DrawsTest do
  use TournamentsApi.DataCase

  alias TournamentsApi.Draws
  alias TournamentsApi.Helpers.PhaseHelpers

  describe "draws" do
    alias TournamentsApi.Draws.Draw

    @valid_attrs %{
      title: "some title",
      matches: [
        %{
          first_team_placeholder: "some-first-team-placeholder",
          second_team_placeholder: "some-second-team-placeholder"
        }
      ]
    }
    @update_attrs %{
      title: "some updated title",
      matches: [
        %{
          first_team_placeholder: "some-updated-first-team-placeholder",
          second_team_placeholder: "some-updated-second-team-placeholder"
        }
      ]
    }
    @invalid_attrs %{title: nil, matches: nil}

    def draw_fixture(attrs \\ %{}) do
      {:ok, draw} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PhaseHelpers.map_phase_id()
        |> Draws.create_draw()

      draw
    end

    test "get_draw!/1 returns the draw with given id" do
      draw = draw_fixture()

      assert Draws.get_draw!(draw.id) ==
               draw
    end

    test "create_draw/1 with valid data creates a draw" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)
      assert {:ok, %Draw{} = draw} = Draws.create_draw(attrs)

      [match] = draw.matches
      assert draw.order == 1
      assert draw.title == "some title"
      assert match.first_team_placeholder == "some-first-team-placeholder"
      assert match.second_team_placeholder == "some-second-team-placeholder"
    end

    test "create_draw/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Draws.create_draw(@invalid_attrs)
    end

    test "create_draw/1 select order for second item" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)

      assert {:ok, %Draw{} = first_draw} = Draws.create_draw(attrs)

      assert {:ok, %Draw{} = second_draw} = Draws.create_draw(attrs)

      assert first_draw.order == 1
      assert second_draw.order == 2
    end

    test "update_draw/2 with valid data updates the draw" do
      draw = draw_fixture()

      assert {:ok, %Draw{} = draw} = Draws.update_draw(draw, @update_attrs)

      [match] = draw.matches
      assert draw.title == "some updated title"
      assert match.first_team_placeholder == "some-updated-first-team-placeholder"
      assert match.second_team_placeholder == "some-updated-second-team-placeholder"
    end

    test "update_draw/2 with invalid data returns error changeset" do
      draw = draw_fixture()
      assert {:error, %Ecto.Changeset{}} = Draws.update_draw(draw, @invalid_attrs)

      assert draw ==
               Draws.get_draw!(draw.id)
    end

    test "delete_draw/1 deletes the draw" do
      draw = draw_fixture()
      assert {:ok, %Draw{}} = Draws.delete_draw(draw)

      assert_raise Ecto.NoResultsError, fn ->
        Draws.get_draw!(draw.id)
      end
    end

    test "change_draw/1 returns a draw changeset" do
      draw = draw_fixture()
      assert %Ecto.Changeset{} = Draws.change_draw(draw)
    end
  end
end
