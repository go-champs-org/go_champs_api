defmodule GoChampsApi.Repo.Migrations.UpdateLiveStateBasedOnIsFinished do
  use Ecto.Migration

  def up do
    execute """
    UPDATE games
    SET live_state = 'ended'
    WHERE is_finished = true
    """

    execute """
    UPDATE games
    SET live_state = 'not_started'
    WHERE is_finished = false
    OR is_finished IS NULL
    """
  end
end
