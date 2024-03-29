defmodule Tarragon.Ecspanse.Lobby.LobbyGamesAgent do
  alias Tarragon.Ecspanse.Lobby.LobbyGame
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def values do
    Agent.get(__MODULE__, &Map.values(&1))
  end

  def put(%LobbyGame{} = game) do
    Agent.update(__MODULE__, &Map.put(&1, game.id, game))
    game
  end

  def remove(%LobbyGame{} = game) do
    Agent.update(__MODULE__, &Map.delete(&1, game.id))
    game
  end
end
