defmodule GoChampsApi.TaskSupervisorBehavior do
  @callback start_child(module(), (() -> any())) :: {:ok, pid()} | {:error, any()}
  @callback start_task(module(), (() -> any())) :: {:ok, pid()} | {:error, any()}
end
