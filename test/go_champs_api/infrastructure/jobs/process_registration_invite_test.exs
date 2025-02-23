defmodule GoChampsApi.Infrastructure.Jobs.ProcessRegistrationInviteTest do
  use ExUnit.Case, async: true
  alias GoChampsApi.Infrastructure.Jobs.ProcessRegistrationInvite

  test "perform/1" do
    registration_invite = %GoChampsApi.Registrations.RegistrationInvite{
      id: 1
    }

    assert :ok =
             ProcessRegistrationInvite.perform(%{
               "registration_invite_id" => registration_invite.id
             })
  end
end
