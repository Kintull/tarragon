defmodule Tarragon.MixProject do
  use Mix.Project

  def project do
    [
      app: :tarragon,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
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
      mod: {Tarragon.Application, []},
      extra_applications: [:logger, :runtime_tools, :observer, :wx]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:comeonin, "~> 2.5"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dns_cluster, "~> 0.1"},
      {:ecspanse, "~> 0.8.0"},
      {:ecto_sql, "~> 3.10"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:ex_machina, "~> 2.7", only: :test},
      {:faker, "~> 0.17"},
      {:finch, "~> 0.13"},
      {:floki, "~> 0.30", only: :test},
      {:gettext, "~> 0.20"},
      {:hammox, "~> 0.7", only: :test},
      {:jason, "~> 1.2"},
      {:mnemonic_slugs, "~> 0.0.3"},
      {:phoenix, "~> 1.7"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_dashboard, "~> 0.8"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20"},
      {:phoenix_storybook, "~> 0.6"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, "~> 0.17"},
      {:swoosh, "~> 1.3"},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:struct_access, "~> 1.1"},
      {:typedstruct, "~> 0.5.2"},
      {:ecspanse_state_machine, ">= 0.3.2"},
      {:backoffice_templates, "~> 1.0.4"},
      {:map_diff, "~> 1.3"},
      {:dart_sass, "~> 0.5.1", runtime: Mix.env() == :dev}
      # {:ecspanse_state_machine, path: "/Users/ketupia/src/phoenix/ecspanse_state_machine"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["sass.install --if-missing", "tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["sass default", "tailwind default", "esbuild default"],
      "assets.deploy": ["sass default", "tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
