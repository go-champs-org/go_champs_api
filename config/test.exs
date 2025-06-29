import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :go_champs_api, GoChampsApiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
# Configure your database
config :go_champs_api, GoChampsApi.Repo,
  username: System.get_env("DATABASE_USERNAME") || "postgres",
  password: System.get_env("DATABASE_PASSWORD") || "admin",
  database: System.get_env("DATABASE_NAME") || "go_champs_db",
  hostname: System.get_env("DATABASE_HOST") || "api-db",
  port: System.get_env("DATABASE_PORT") || "5432",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

config :go_champs_api, Oban, testing: :manual

config :recaptcha,
  secret: "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"
