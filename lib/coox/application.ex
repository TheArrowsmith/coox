defmodule Coox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CooxWeb.Telemetry,
      Coox.Repo,
      {DNSCluster, query: Application.get_env(:coox, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Coox.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Coox.Finch},
      # Start a worker by calling: Coox.Worker.start_link(arg)
      # {Coox.Worker, arg},
      # Start to serve requests, typically the last entry
      CooxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Coox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CooxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
