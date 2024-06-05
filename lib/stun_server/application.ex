defmodule StunServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      StunServerWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:stun_server, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: StunServer.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: StunServer.Finch},
      # Start a worker by calling: StunServer.Worker.start_link(arg)
      # {StunServer.Worker, arg},
      # Start to serve requests, typically the last entry
      StunServerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StunServer.Supervisor]
    supervisor_resp = Supervisor.start_link(children, opts)
    IO.inspect("-------------------------------------- Put Your Stun Port Code Here! --------------------------------------")
    :stun_listener.add_listener({127, 0, 0, 1}, 3478, :udp, [])
    supervisor_resp
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StunServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
