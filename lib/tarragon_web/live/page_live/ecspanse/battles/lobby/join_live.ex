defmodule TarragonWeb.PageLive.Ecspanse.Battles.Lobby.JoinLive do
  alias Tarragon.Ecspanse.Lobby.LobbyGame
  alias Tarragon.Ecspanse.Lobby.LobbyGamesAgent
  use TarragonWeb, :live_view

  defp assign_lobby_game(socket, nil) do
    socket |> push_navigate(to: ~p"/ecspanse/battles/lobby")
  end

  defp assign_lobby_game(socket, lobby_game) do
    IO.inspect(lobby_game, label: "lobby_game")
    IO.inspect(socket.assigns.user_id, label: "socket.assigns.user_id")

    teams_and_professions =
      for team <- [:red, :blue],
          profession <- [:machine_gunner, :pistolero, :sniper],
          do: {team, profession}

    socket
    |> assign(:lobby_game, lobby_game)
    |> assign(:teams_and_professions, teams_and_professions)
    |> assign(
      :player_combatant_key,
      LobbyGame.get_combatant_key(lobby_game, socket.assigns.user_id)
    )
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

    selected_lobby_game = find_game_by_id(LobbyGamesAgent.values(), lobby_game_id)

    socket
    |> assign_lobby_game(selected_lobby_game)
    |> assign_new(:enrolled, fn -> nil end)
    |> ok()
  end

  def handle_event(
        "assign_player",
        %{"team" => team, "profession" => profession},
        socket
      ) do
    lobby_game = socket.assigns.lobby_game

    IO.inspect(lobby_game.player_combatants,
      label: "lobby_game.player_combatants"
    )

    # assign new role - also clears old role
    lobby_game =
      LobbyGame.assign_player_combatant(lobby_game, team, profession, socket.assigns.user_id)

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
        push_navigate(socket, to: ~p"/ecspanse/battles/play?game_id=#{g}")
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
