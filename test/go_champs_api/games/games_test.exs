defmodule GoChampsApi.GamesTest do
  alias GoChampsApi.Helpers.TournamentHelpers
  use GoChampsApi.DataCase
  use Oban.Testing, repo: GoChampsApi.Repo

  alias GoChampsApi.Helpers.PhaseHelpers
  alias GoChampsApi.Games
  alias GoChampsApi.Phases

  describe "games" do
    alias GoChampsApi.Games.Game

    @valid_attrs %{
      away_score: 10,
      datetime: "2019-08-25T16:59:27.116Z",
      home_score: 20,
      location: "some location",
      youtube_code: "1234"
    }
    @update_attrs %{
      away_score: 20,
      datetime: "2019-08-25T16:59:27.116Z",
      home_score: 30,
      location: "another location",
      youtube_code: "5678"
    }
    @invalid_attrs %{phase_id: nil}

    def game_fixture(attrs \\ %{}) do
      {:ok, game} =
        attrs
        |> Enum.into(@valid_attrs)
        |> PhaseHelpers.map_phase_id()
        |> Games.create_game()

      game
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()

      result_game = Games.get_game!(game.id)

      assert result_game.id == game.id
    end

    test "get_game_organization/1 returns the organization with a give team id" do
      game = game_fixture()

      organization = Games.get_game_organization!(game.id)

      game_organization = Phases.get_phase_organization!(game.phase_id)

      assert organization.name == "some organization"
      assert organization.slug == "some-slug"
      assert organization.id == game_organization.id
    end

    test "create_game/1 with valid data creates a game and queue side effects" do
      attrs = PhaseHelpers.map_phase_id(@valid_attrs)

      assert {:ok, %Game{} = game} = Games.create_game(attrs)

      assert game.away_score == attrs.away_score
      assert game.home_score == attrs.home_score
      assert game.location == attrs.location
      assert game.youtube_code == attrs.youtube_code

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.GeneratePhaseResults,
        args: %{phase_id: game.phase_id}
      )
    end

    test "create_game/1 with live_state ended creates a game and queue process relevant update for the game tournament" do
      attrs =
        Map.merge(@valid_attrs, %{live_state: :ended})
        |> PhaseHelpers.map_phase_id()

      assert {:ok, %Game{} = game} = Games.create_game(attrs)

      assert game.away_score == attrs.away_score
      assert game.home_score == attrs.home_score
      assert game.location == attrs.location
      assert game.youtube_code == attrs.youtube_code
      assert game.is_finished == true

      {:ok, tournament_id} = Phases.get_phases_tournament_id([%{"id" => game.phase_id}])

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate,
        args: %{tournament_id: tournament_id}
      )
    end

    test "create_game/1 with live_state in_progress creates a game and queue process relevant update for the game tournament" do
      attrs =
        Map.merge(@valid_attrs, %{live_state: :in_progress})
        |> PhaseHelpers.map_phase_id()

      assert {:ok, %Game{} = game} = Games.create_game(attrs)

      assert game.away_score == attrs.away_score
      assert game.home_score == attrs.home_score
      assert game.location == attrs.location
      assert game.youtube_code == attrs.youtube_code
      assert game.is_finished == nil

      {:ok, tournament_id} = Phases.get_phases_tournament_id([%{"id" => game.phase_id}])

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate,
        args: %{tournament_id: tournament_id}
      )
    end

    test "create_game/1 with live_state not_started creates a game and does not queue process relevant update for the game tournament" do
      attrs =
        Map.merge(@valid_attrs, %{live_state: :not_started})
        |> PhaseHelpers.map_phase_id()

      assert {:ok, %Game{} = game} = Games.create_game(attrs)

      assert game.away_score == attrs.away_score
      assert game.home_score == attrs.home_score
      assert game.location == attrs.location
      assert game.youtube_code == attrs.youtube_code
      assert game.is_finished == nil

      refute_enqueued(worker: GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate)
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Games.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game and queue side efffects" do
      game = game_fixture()

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id})

      {:ok, %Game{} = updated_game} = Games.update_game(game, attrs)

      assert updated_game.away_score == attrs.away_score
      assert updated_game.home_score == attrs.home_score
      assert updated_game.location == attrs.location
      assert updated_game.youtube_code == attrs.youtube_code

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.GeneratePhaseResults,
        args: %{phase_id: game.phase_id}
      )
    end

    test "update_game/2 with not_started does not queue process relevant update for the game tournament" do
      game = game_fixture()

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id, live_state: :not_started})

      {:ok, %Game{} = _updated_game} = Games.update_game(game, attrs)

      refute_enqueued(worker: GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate)
    end

    test "update_game/2 with is_finished false but current game live_state is :ended updates the game" do
      game = game_fixture(%{live_state: :ended})

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id, is_finished: false})

      {:ok, %Game{} = updated_game} = Games.update_game(game, attrs)

      assert updated_game.is_finished == false
      assert updated_game.live_state == :not_started
      assert updated_game.live_ended_at == nil
    end

    test "update_game/2 with valid data but current game live_state is :in_progress returns error changeset" do
      game = game_fixture(%{live_state: :in_progress})

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id})

      assert {:error, %Ecto.Changeset{}} = Games.update_game(game, attrs)
    end

    test "update_game/2 with live_state :ended but current game live_state is :in_progress updates the game" do
      game = game_fixture(%{live_state: :in_progress})

      attrs = %{live_state: :ended}

      {:ok, %Game{} = updated_game} = Games.update_game(game, attrs)

      assert updated_game.is_finished == true
      assert updated_game.live_state == :ended
      assert updated_game.live_ended_at != nil
    end

    test "update_game/2 with is_progress live_state updates the live_started_at" do
      game = game_fixture()

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id, live_state: :in_progress})

      {:ok, %Game{} = updated_game} = Games.update_game(game, attrs)

      assert updated_game.live_started_at != nil
    end

    test "update_game/2 with in_progress live_state queues process relevant update for the game tournament" do
      game = game_fixture()

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id, live_state: :in_progress})

      {:ok, %Game{} = _updated_game} = Games.update_game(game, attrs)

      {:ok, tournament_id} = Phases.get_phases_tournament_id([%{"id" => game.phase_id}])

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate,
        args: %{tournament_id: tournament_id}
      )
    end

    test "update_game/2 with ended live_state updates the is_finished field to true and live_ended_at" do
      game = game_fixture()

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id, live_state: :ended})

      {:ok, %Game{} = updated_game} = Games.update_game(game, attrs)

      assert updated_game.is_finished == true
      assert updated_game.live_ended_at != nil
    end

    test "update_game/2 with ended live_state queues process relevant update for the game tournament" do
      game = game_fixture()

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id, live_state: :ended})

      {:ok, %Game{} = _updated_game} = Games.update_game(game, attrs)

      {:ok, tournament_id} = Phases.get_phases_tournament_id([%{"id" => game.phase_id}])

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.ProcessRelevantUpdate,
        args: %{tournament_id: tournament_id}
      )
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()

      assert {:error, %Ecto.Changeset{}} = Games.update_game(game, @invalid_attrs)

      result_game = Games.get_game!(game.id)

      assert result_game.id == game.id
    end

    test "update_game/2 with is_finished true updates live_state to :ended and live_ended_at" do
      game = game_fixture()

      attrs = Map.merge(@update_attrs, %{phase_id: game.phase_id, is_finished: true})

      {:ok, %Game{} = updated_game} = Games.update_game(game, attrs)

      assert updated_game.live_state == :ended
      assert updated_game.live_ended_at != nil
    end

    test "delete_game/1 deletes the game and queue side effects" do
      game = game_fixture()
      assert {:ok, %Game{}} = Games.delete_game(game)

      assert_enqueued(
        worker: GoChampsApi.Infrastructure.Jobs.GeneratePhaseResults,
        args: %{phase_id: game.phase_id}
      )

      assert_raise Ecto.NoResultsError, fn ->
        Games.get_game!(game.id)
      end
    end

    test "generate_results/1 generates results for the game" do
      {:ok, tournament} = TournamentHelpers.create_tournament_basketball_5x5()
      game = game_fixture(%{tournament_id: tournament.id})

      assert {:ok, _} = Games.generate_results(game.id)
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Games.change_game(game)
    end
  end
end
