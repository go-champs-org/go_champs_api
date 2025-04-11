defmodule GoChampsApi.Repo do
  use Ecto.Repo,
    otp_app: :go_champs_api,
    adapter: Ecto.Adapters.Postgres

  use Ecto.SoftDelete.Repo
end
