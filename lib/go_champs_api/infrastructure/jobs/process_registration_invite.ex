defmodule GoChampsApi.Infrastructure.Jobs.ProcessRegistrationInvite do
  use Oban.Worker, queue: :process_registration_invite

  alias GoChampsApi.Registrations

  @impl true
  def perform(%Oban.Job{args: %{"registration_invite_id" => registration_invite_id}}) do
    case Registrations.process_registration_invite(registration_invite_id) do
      :ok -> {:ok, "Registration invite processed"}
      :error -> {:error, "Registration invite could not be processed"}
    end
  end
end
