Mox.defmock(GoChampsApi.TaskSupervisorMock, for: GoChampsApi.TaskSupervisorBehavior)
Application.put_env(:go_champs_api, :task_supervisor, GoChampsApi.TaskSupervisorMock)
ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(GoChampsApi.Repo, :manual)
