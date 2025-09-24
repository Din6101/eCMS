defmodule ECMS.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ECMSWeb.Telemetry,
      ECMS.Repo,
      {DNSCluster, query: Application.get_env(:eCMS, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ECMS.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ECMS.Finch},
      # Start a worker by calling: ECMS.Worker.start_link(arg)
      # {ECMS.Worker, arg},
      # Start to serve requests, typically the last entry
      ECMSWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ECMS.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ECMSWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
