defmodule TarragonWeb.PageLive.Ecspanse.Battles.Lobby.JoinLive do
  alias Tarragon.Ecspanse.Lobby.LobbyGame
  alias Tarragon.Ecspanse.Lobby.LobbyGamesAgent
  use TarragonWeb, :live_view

  defp assign_lobby_game(socket, nil) do
    socket |> push_navigate(to: ~p"/ecspanse/battles/lobby")
  end

  defp assign_lobby_game(socket, lobby_game) do
    teams_and_professions =
      for team <- [:red, :blue],
          profession <- [:machine_gunner, :pistolero, :sniper],
          do: {team, profession}

    player_combatants =
      teams_and_professions
      |> Enum.reduce(%{}, fn {team, profession}, acc ->
        Map.put(acc, {team, profession}, LobbyGame.get_user_id(lobby_game, team, profession))
      end)

    socket
    |> assign(:lobby_game, lobby_game)
    |> assign(:player_combatants, player_combatants)
  end

  defp ensure_user_id(socket, session) do
    case Map.get(socket.assigns, :user_id) do
      nil ->
        id = Map.get(session, "user_id", Enum.random(100..10_000))
        assign(socket, :user_id, id)

      _ ->
        socket
    end
  end

  defp find_game_by_id(_games, nil), do: nil

  defp find_game_by_id(games, lobby_game_id) when is_binary(lobby_game_id),
    do: find_game_by_id(games, String.to_integer(lobby_game_id))

  defp find_game_by_id(games, lobby_game_id), do: Enum.find(games, &(&1.id == lobby_game_id))

  def mount(%{"id" => lobby_game_id}, session, socket) do
    socket = ensure_user_id(socket, session)

    if connected?(socket), do: Phoenix.PubSub.subscribe(Tarragon.PubSub, "lobby_games")

    lobby_game = find_game_by_id(LobbyGamesAgent.values(), lobby_game_id)

    socket
    |> assign_lobby_game(lobby_game)
    |> assign_new(:enrolled, fn -> nil end)
    |> ok()
  end

  def handle_event(
        "assign_player",
        %{"team" => team, "profession" => profession},
        socket
      ) do
    lobby_game = socket.assigns.lobby_game

    # assign new role - also clears old role
    lobby_game =
      LobbyGame.assign_player_combatant(
        lobby_game,
        String.to_existing_atom(team),
        String.to_existing_atom(profession),
        socket.assigns.user_id
      )

    LobbyGamesAgent.put(lobby_game)

    Phoenix.PubSub.broadcast(
      Tarragon.PubSub,
      "lobby_games",
      {"lobby_games", "player_assignment_changed", lobby_game.id}
    )

    socket
    |> assign_lobby_game(lobby_game)
    |> assign(enrolled: lobby_game.id)
    |> noreply()
  end

  def handle_event(
        "unassign_player",
        %{"team" => team, "profession" => profession},
        socket
      ) do
    lobby_game = socket.assigns.lobby_game

    # assign new role - also clears old role
    lobby_game =
      LobbyGame.clear_player_combatant(
        lobby_game,
        String.to_existing_atom(team),
        String.to_existing_atom(profession)
      )

    LobbyGamesAgent.put(lobby_game)

    Phoenix.PubSub.broadcast(
      Tarragon.PubSub,
      "lobby_games",
      {"lobby_games", "player_assignment_changed", lobby_game.id}
    )

    socket
    |> assign_lobby_game(lobby_game)
    |> assign(enrolled: lobby_game.id)
    |> noreply()
  end

  def handle_event("play", _params, socket) do
    case socket.assigns.lobby_game do
      nil ->
        socket

      %LobbyGame{} = g ->
        Tarragon.Ecspanse.Battles.Api.spawn_battle(g)
        Process.sleep(100)

        push_navigate(socket,
          to: ~p"/ecspanse/battles/play?game_id=#{g}&user_id=#{socket.assigns.user_id}"
        )
    end
    |> noreply()
  end

  def handle_info({"lobby_games", "player_assignment_changed", game_id}, socket) do
    if socket.assigns.lobby_game != nil &&
         socket.assigns.lobby_game.id == game_id do
      lobby_game = find_game_by_id(LobbyGamesAgent.values(), game_id)

      socket |> assign_lobby_game(lobby_game)
    else
      socket
    end
    |> noreply()
  end
end
