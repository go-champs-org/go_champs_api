defmodule GoChampsApi.Infrastructure.Jobs.ProcessRegistrationInvite do
  use Oban.Worker, queue: :process_registration_invite

  @impl true
  def perform(%{"registration_invite_id" => registration_invite_id}) do
  end
end
