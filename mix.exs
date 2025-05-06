defmodule GoChampsApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :go_champs_api,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext, :phoenix_swagger] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {GoChampsApi.Application, []},
      extra_applications: [:corsica, :logger, :runtime_tools, :recaptcha]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support", "test/support/helpers"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:phoenix_ecto, "~> 4.0"},
      {:poison, "~> 3.1"},
      {:ecto_sql, "~> 3.10.0"},
      {:postgrex, ">= 0.17.5"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.1"},
      {:plug, "~> 1.0"},
      {:corsica, "~> 1.0"},
      {:phoenix_swagger, "~> 0.8"},
      {:ex_json_schema, "~> 0.5"},
      {:guardian, "~> 2.0"},
      {:comeonin, "~> 5.3.1"},
      {:bcrypt_elixir, "~> 2.2.0"},
      {:recaptcha, "~> 3.0"},
      {:quantum, "~> 3.0"},
      {:amqp, "~> 3.3"},
      {:amqp_client, "~> 3.12"},
      {:oban, "~> 2.15.0"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:csv, "~> 3.2"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
