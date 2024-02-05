defmodule TarragonWeb.PageLive.BattleScreen do
  use TarragonWeb, :live_view
  alias Tarragon.Accounts
  alias Tarragon.Battles

  @impl true
  def mount(_params, %{"user_id" => user_id}, socket) do
    character = Accounts.impl().get_character_by_user_id!(user_id)

    socket =
      case Battles.impl().get_active_participant(character) do
        nil ->
          push_redirect(socket, to: ~p"/game_screen")

        %{user_character_id: character_id} = participant ->
          room = Battles.impl().get_character_active_room(character_id)

          {ally_team, enemy_team} = split_ally_enemy_teams(character.id, room.participants)

          character_id_to_bonuses = for char <- ally_team ++ enemy_team do
            {char.id, Battles.impl().build_character_bonuses(char.id)}
          end

          character_id_to_initial_position = for {_, b} <- character_id_to_bonuses do

            #team a - A10 A5 A3 Team b - B10 B6 B0
            # -10 -9 -8 -7 -6 -5 -4 -3 -2 -1  0  1  2  3  4  5  6  7  8  9  10
            # A10             A5    A3        B0       B6          B10
            {b.character_id, b.range_bonus}
          end

          submitted_players_count = Battles.impl().count_submitted(room.id)

          current_player_eliminated =
            Enum.find(room.participants, &(&1.user_character_id == character.id)).eliminated

          show_victory = show_victory?(room, participant)
          show_defeat = show_defeat?(room, participant)
          seconds_left = Battles.impl().battle_turn_seconds_left(room.id)

          socket
          |> assign(battle_room_id: room.id)
          |> assign(ally_team: ally_team)
          |> assign(enemy_team: enemy_team)
          |> assign(character_id_to_bonuses: character_id_to_bonuses)
          |> assign(current_turn: room.current_turn)
          |> assign(turn_duration_sec: seconds_left)
          |> assign(seconds_left: seconds_left)
          |> assign(logs: room.logs)
          |> assign(current_player_character_id: character.id)
          |> assign(current_player_eliminated: current_player_eliminated)
          |> assign(current_target_id: nil)
          |> assign(current_move_action: nil)
          |> assign(current_attack_action: nil)
          |> assign(attack_action_allowed: true)
          |> assign(submit_action_allowed: false)
          |> assign(current_action_confirmed: nil)
          |> assign(submitted_players_count: submitted_players_count)
          |> assign(players_total_count: length(enemy_team) + length(ally_team))
          |> assign(show_victory_modal: show_victory)
          |> assign(show_defeat_modal: show_defeat)
      end

    Process.send_after(self(), :tick_timer, 1000)

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_info(:tick_timer, socket) do
    seconds_left = Battles.impl().battle_turn_seconds_left(socket.assigns.battle_room_id)
    room = Battles.impl().get_room!(socket.assigns.battle_room_id)
    submitted_players_count = Battles.impl().count_submitted(socket.assigns.battle_room_id)
    turn_ended = room.current_turn != socket.assigns.current_turn

    socket =
      if turn_ended do
        IO.inspect("BattleScreen turn ended")
        character_id = socket.assigns.current_player_character_id

        # reload room and character HP from DB
        room = Battles.impl().get_character_active_room(character_id)

        current_participant =
          Enum.find(room.participants, &(&1.user_character_id == character_id))

        show_victory = show_victory?(room, current_participant)
        show_defeat = show_defeat?(room, current_participant)

        {ally_team, enemy_team} = split_ally_enemy_teams(character_id, room.participants)

        socket
        |> assign(ally_team: ally_team)
        |> assign(enemy_team: enemy_team)
        |> assign(current_turn: room.current_turn)
        |> assign(seconds_left: seconds_left)
        |> assign(current_target_id: nil)
        |> assign(current_move_action: nil)
        |> assign(current_attack_action: nil)
        |> assign(current_action_confirmed: nil)
        |> assign(attack_action_allowed: true)
        |> assign(submit_action_allowed: false)
        |> assign(current_player_eliminated: current_participant.eliminated)
        |> assign(submitted_players_count: submitted_players_count)
        |> assign(show_victory_modal: show_victory)
        |> assign(show_defeat_modal: show_defeat)
        |> assign(logs: room.logs)
      else
        socket
        |> assign(seconds_left: seconds_left)
      end

    Process.send_after(self(), :tick_timer, 1000)

    {:noreply, socket}
  end

  @impl true
  def handle_event(move_action = "move" <> _, _, socket) do
    attack_action = socket.assigns.current_attack_action
    attack_action_allowed = attack_action_allowed(move_action)
    current_attack_action = if attack_action_allowed, do: attack_action, else: nil

    socket =
      socket
      |> assign(current_move_action: move_action)
      |> assign(submit_action_allowed: submit_action_allowed(move_action, attack_action))
      |> assign(attack_action_allowed: attack_action_allowed)
      |> assign(current_attack_action: current_attack_action)

    {:noreply, socket}
  end

  def handle_event(attack_action = "attack" <> _, _, socket) do
    move_action = socket.assigns.current_move_action

    socket =
      socket
      |> assign(current_attack_action: attack_action)
      |> assign(submit_action_allowed: submit_action_allowed(move_action, attack_action))

    {:noreply, socket}
  end

  def handle_event("target_id-" <> target_id, _, socket) do
    socket =
      socket
      |> assign(current_target_id: String.to_integer(target_id))

    {:noreply, socket}
  end

  def handle_event("confirm-action", _, socket) do
    IO.inspect("TarragonWeb.PageLive.BattleScreen - attack_submit")
    # TODO: replace target selector with a click on an enemy character
    target_id =
      socket.assigns.enemy_team
      |> Enum.filter(&(&1.current_health > 0))
      |> Enum.map(& &1.id)
      |> Enum.at(0)

    socket =
      socket
      |> assign(current_target_id: target_id)

    battle_room_id = socket.assigns.battle_room_id

    attack_map = %{
      character_id: socket.assigns.current_player_character_id,
      move: socket.assigns.current_move_action,
      attack: socket.assigns.current_attack_action,
      target_id: socket.assigns.current_target_id
    }

    Battles.impl().submit_battle_action(battle_room_id, attack_map)

    socket =
      socket
      |> assign(current_action_confirmed: true)

    {:noreply, socket}
  end

  def handle_event("versus_closure_modal_closed", _, socket) do
    # update participant closure_shown
    character_id = socket.assigns.current_player_character_id
    IO.inspect("versus_closure_modal_closed for #{character_id}")
    room = Battles.impl().get_character_active_room(character_id)
    current_participant = Enum.find(room.participants, &(&1.user_character_id == character_id))

    Battles.impl().update_participant(current_participant, %{closure_shown: true})

    {:noreply, push_redirect(socket, to: ~p"/game_screen")}
  end

  defp team_a_characters(participants) do
    participants
    |> Enum.filter(& &1.team_a)
    |> Enum.map(& &1.user_character)
  end

  defp team_b_characters(participants) do
    participants
    |> Enum.filter(& &1.team_b)
    |> Enum.map(& &1.user_character)
  end

  def split_ally_enemy_teams(character_id, participants) do
    team_a_characters = team_a_characters(participants)
    team_b_characters = team_b_characters(participants)

    if character_id in Enum.map(team_a_characters, & &1.id) do
      {team_a_characters, team_b_characters}
    else
      {team_b_characters, team_a_characters}
    end
  end

  defp submit_action_allowed(move, attack) do
    (move in ["move-left-and-step", "move-center-and-step", "move-right-and-step"] and
       is_nil(attack)) or
      (!is_nil(move) and !is_nil(attack))
  end

  defp attack_action_allowed(move) do
    move in ["move-left", "move-center", "move-right"]
  end

  defp show_victory?(room, current_participant) do
    (room.winner_team == :team_a and current_participant.team_a) ||
      (room.winner_team == :team_b and current_participant.team_b)
  end

  def show_defeat?(room, current_participant) do
    (room.winner_team == :team_a and current_participant.team_b) ||
      (room.winner_team == :team_b and current_participant.team_a) ||
      room.winner_team == :draw
  end
end
