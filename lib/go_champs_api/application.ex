defmodule GoChampsApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      GoChampsApi.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: GoChampsApiWeb.PubSub},
      # Start the endpoint when the application starts
      GoChampsApiWeb.Endpoint,
      # Starts a worker by calling: GoChampsApi.Worker.start_link(arg)
      # {GoChampsApi.Worker, arg},
      GoChampsApi.Scheduler,
      {Oban, Application.fetch_env!(:go_champs_api, Oban)},
      GoChampsApi.Infrastructure.RabbitMQ
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GoChampsApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    GoChampsApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
