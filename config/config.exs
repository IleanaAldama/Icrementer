# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :incrementer,
  ecto_repos: [Incrementer.Repo]

# Configures the endpoint
config :incrementer, IncrementerWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: IncrementerWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Incrementer.PubSub,
  live_view: [signing_salt: "DFCv2dEV"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :incrementer, Incrementer.Mailer, adapter: Swoosh.Adapters.Local

config :incrementer, Incrementer.DBWorker,
  max_updates: 1000,
  polling_time: 5_000

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :result]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
