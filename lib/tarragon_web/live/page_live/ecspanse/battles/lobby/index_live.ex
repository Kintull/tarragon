defmodule TarragonWeb.PageLive.Ecspanse.Battles.Lobby.IndexLive do
  alias Tarragon.Ecspanse.GameParameters
  alias Tarragon.Ecspanse.Lobby.LobbyGamesAgent
  alias Tarragon.Ecspanse.Lobby.LobbyGame
  use TarragonWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(Tarragon.PubSub, "lobby_games")
    end

    # make sure there are some games in the lobby
    Enum.each(Range.new(length(LobbyGamesAgent.values()), 3, 1), fn _ ->
      game_parameters =
        GameParameters.new(%{
          id: System.monotonic_time()
        })

      LobbyGamesAgent.put(LobbyGame.new(game_parameters))
    end)

    games = LobbyGamesAgent.values()

    socket
    |> assign(:games, games)
    |> assign_new(:enrolled, fn -> nil end)
    |> ok()
  end
end
