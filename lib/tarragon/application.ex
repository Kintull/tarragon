defmodule Tarragon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children =
      [
        TarragonWeb.Telemetry,
        Tarragon.Repo,
        {DNSCluster, query: Application.get_env(:tarragon, :dns_cluster_query) || :ignore},
        {Phoenix.PubSub, name: Tarragon.PubSub},
        # Start the Finch HTTP client for sending emails
        {Finch, name: Tarragon.Finch},
        # Start a worker by calling: Tarragon.Worker.start_link(arg)
        # {Tarragon.Worker, arg},
        # Start to serve requests, typically the last entry,

        TarragonWeb.Endpoint,
        Tarragon.Ecspanse.Manager
      ] ++ workers()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tarragon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp workers() do
    case Application.get_env(:tarragon, :start_workers) do
      true ->
        [
          #          {Tarragon.Battles.BattleRoom, name: Tarragon.Battles.BattleRoom},
          #          {Tarragon.Battles.BattleBots, name: Tarragon.Battles.BattleBots},
          #          {Tarragon.Battles.LobbyTracker, name: Tarragon.Battles.LobbyTracker},
          #          {Tarragon.Accounts.CharacterHealer, name: Tarragon.Accounts.CharacterHealer}
        ]

      false ->
        []
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TarragonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
