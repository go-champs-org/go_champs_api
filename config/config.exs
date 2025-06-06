# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :go_champs_api,
  ecto_repos: [GoChampsApi.Repo]

# Configures the endpoint
config :go_champs_api, GoChampsApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "imta0fFj1/DTKBsA9UFU4NP9/3U2KQAAi9TqID70AdjSC1sBxS8D1ddhrkRAHP5X",
  render_errors: [view: GoChampsApiWeb.ErrorView, accepts: ~w(json)],
  pubsub_server: GoChampsApi.PubSub

config :go_champs_api, GoChampsApiWeb.Auth.Guardian,
  issuer: "go_champs_api",
  secret_key:
    System.get_env("SECRET_AUTH_KEY") ||
      "ptHFgyK8ePlG2uYnwP7KJhEzfp1s/Xmu6Agtj9iuJA5IU8+g8CCi8zScfaaT+yOX"

config :go_champs_api, Oban,
  repo: GoChampsApi.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [
    default: 10,
    after_tournament_creation: 1,
    generate_aggregated_player_stats: 1,
    generate_aggregated_team_stats: 1,
    generate_game_results: 1,
    generate_phase_results: 1,
    generate_team_stats_logs_for_game: 1,
    process_registration_invite: 1,
    process_relevant_update: 1
  ]

# config :go_champs_api, :phoenix_swagger,
#   swagger_files: %{
#     "priv/static/swagger.json" => [
#       router: GoChampsApiWeb.Router,
#       endpoint: GoChampsApiWeb.Endpoint
#     ]
#   }

config :go_champs_api, GoChampsApi.Infrastructure.RabbitMQ,
  host: System.get_env("RABBIT_MQ_HOST") || "moose-01.rmq.cloudamqp.com",
  port: System.get_env("RABBIT_MQ_PORT") || 5672,
  username: System.get_env("RABBIT_MQ_USERNAME") || "viezbksg",
  password: System.get_env("RABBIT_MQ_PASSWORD") || "lgwUC_UNeUXz-FyHEM9vcl9ItOvLx_47",
  virtual_host: System.get_env("RABBIT_MQ_VHOST") || "viezbksg"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :recaptcha,
  secret: System.get_env("RECAPTCHA_SECRET_KEY") || "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"

config :recaptcha, :json_library, Jason

config :ex_aws,
  http_client: GoChampsApi.ExAwsHTTPoisonAdapter,
  access_key_id: System.get_env("R2_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("R2_SECRET_ACCESS_KEY"),
  region: "auto",
  s3: [
    scheme: "https://",
    host: "a0186fb988e3bd8d1b9d4a5a398f9bd1.r2.cloudflarestorage.com",
    region: "auto"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
