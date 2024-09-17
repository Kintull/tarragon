# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tarragon,
  ecto_repos: [Tarragon.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :tarragon, TarragonWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: TarragonWeb.ErrorHTML, json: TarragonWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Tarragon.PubSub,
  live_view: [signing_salt: "C+7E5NWU"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :tarragon, Tarragon.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.3.2",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=../priv/static/assets/app.css.tailwind
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :dart_sass,
       version: "1.54.5",
       default: [
         args: ~w(css/app.scss ../priv/static/assets/app.css.tailwind),
         cd: Path.expand("../assets", __DIR__)
       ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tarragon, :battles_impl, Tarragon.Battles.Impl
config :tarragon, :inventory_impl, Tarragon.Inventory.Impl
config :tarragon, :accounts_impl, Tarragon.Accounts.Impl
config :tarragon, :start_workers, true

config :tarragon, :start_versus_immediately, true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
