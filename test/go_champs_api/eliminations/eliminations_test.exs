defmodule GoChampsApi.EliminationsTest do
  use GoChampsApi.DataCase

  alias GoChampsApi.Eliminations
  alias GoChampsApi.Helpers.PhaseHelpers

  random_uuid = "d6a40c15-7363-4179-9f7b-8b17cc6cf32c"

  describe "eliminations" do
    alias GoChampsApi.Eliminations.Elimination
    alias GoChampsApi.Phases

    @valid_attrs %{
      title: "some title",
      info: "some info",
      team_stats: [
        %{placeholder: "placeholder", team_id: random_uuid, stats: %{"key" => "value"}}
      ]
    }
    @update_attrs %{
      title: "some updated title",
      info: "some updated info",
      team_stats: [
        %{placeholder: "placeholder updated", team_id: random_uuid, stats: %{"key" => "updated"}}
      ]
    }
    @invalid_attrs %{team_stats: nil}

    def elimination_fixture(attrs \\ %{}) do
      {:ok, elimination} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PhaseHelpers.map_phase_id()
        |> Eliminations.create_elimination()

      elimination
    end

    test "get_elimination!/1 returns the elimination with given id" do
      elimination = elimination_fixture()

      assert Eliminations.get_elimination!(elimination.id) == elimination
    end

    test "create_elimination/1 with valid data creates a elimination" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)
      assert {:ok, %Elimination{} = elimination} = Eliminations.create_elimination(attrs)

      assert elimination.title == "some title"
      assert elimination.info == "some info"
      assert elimination.order == 1
      [team_stat] = elimination.team_stats
      assert team_stat.placeholder == "placeholder"
      assert team_stat.team_id == "d6a40c15-7363-4179-9f7b-8b17cc6cf32c"
      assert team_stat.stats == %{"key" => "value"}
    end

    test "create_elimination/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Eliminations.create_elimination(@invalid_attrs)
    end

    test "create_elimination/1 select order for second item" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)

      assert {:ok, %Elimination{} = first_elimination} = Eliminations.create_elimination(attrs)

      assert {:ok, %Elimination{} = second_elimination} = Eliminations.create_elimination(attrs)

      assert first_elimination.order == 1
      assert second_elimination.order == 2
    end

    test "create_elimination/1 set order as 1 for new elimination" do
      first_attrs = PhaseHelpers.map_phase_id(@valid_attrs)

      assert {:ok, %Elimination{} = first_elimination} =
               Eliminations.create_elimination(first_attrs)

      phase = Phases.get_phase!(first_elimination.phase_id)

      {:ok, second_phase} =
        Phases.create_phase(%{
          is_in_progress: true,
          title: "some title",
          type: "elimination",
          elimination_stats: [%{"title" => "stat title"}],
          tournament_id: phase.tournament_id
        })

      second_attrs = %{
        title: "some title",
        info: "some info",
        team_stats: [],
        phase_id: second_phase.id
      }

      assert {:ok, %Elimination{} = second_elimination} =
               Eliminations.create_elimination(second_attrs)

      assert first_elimination.order == 1
      assert second_elimination.order == 1
    end

    test "update_elimination/2 with valid data updates the elimination" do
      elimination = elimination_fixture()

      assert {:ok, %Elimination{} = elimination} =
               Eliminations.update_elimination(elimination, @update_attrs)

      assert elimination.title == "some updated title"
      assert elimination.info == "some updated info"
      [team_stat] = elimination.team_stats
      assert team_stat.placeholder == "placeholder updated"
      assert team_stat.team_id == "d6a40c15-7363-4179-9f7b-8b17cc6cf32c"
      assert team_stat.stats == %{"key" => "updated"}
    end

    test "update_elimination/2 with invalid data returns error changeset" do
      elimination = elimination_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Eliminations.update_elimination(elimination, @invalid_attrs)

      assert elimination ==
               Eliminations.get_elimination!(elimination.id)
    end

    test "delete_elimination/1 deletes the elimination" do
      elimination = elimination_fixture()
      assert {:ok, %Elimination{}} = Eliminations.delete_elimination(elimination)

      assert_raise Ecto.NoResultsError, fn ->
        Eliminations.get_elimination!(elimination.id)
      end
    end

    test "change_elimination/1 returns a elimination changeset" do
      elimination = elimination_fixture()
      assert %Ecto.Changeset{} = Eliminations.change_elimination(elimination)
    end
  end
end
