defmodule Incrementer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Incrementer.Repo,
      # Start the Telemetry supervisor
      IncrementerWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Incrementer.PubSub},
      # Start the Endpoint (http/https)
      IncrementerWeb.Endpoint,
      # Start a worker by calling: Incrementer.Worker.start_link(arg)
      # {Incrementer.Worker, arg}
      Incrementer.Increment
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Incrementer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    IncrementerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
