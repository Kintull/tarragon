defmodule Tarragon.Battles.BattleRoom do
  @moduledoc """
  Process that tracks rooms that await start
  """

  use GenServer

  alias Tarragon.Repo
  alias Tarragon.Accounts
  alias Tarragon.Battles
  alias Tarragon.Battles.Participant
  alias Tarragon.Battles.Room
  alias Tarragon.Accounts.UserCharacter
  alias Tarragon.Battles.CharacterBattleBonuses
  alias Tarragon.Battles.Room.BattleLogEntry

  alias Ecto.Multi

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  defmodule RoomState do
    defstruct [
      :id,
      :room,
      :characters,
      :character_battle_bonuses,
      :turn_character_actions,
      :bot_participants,
      :team_a_participants,
      :team_b_participants,
      :current_turn,
      :seconds_left
    ]

    @type character_id :: integer
    @type target_id :: character_id
    @type turn_id :: integer
    @type t :: %__MODULE__{
            id: integer,
            room: Room.t(),
            bot_participants: [Participant.t()],
            team_a_participants: [Participant.t()],
            team_b_participants: [Participant.t()],
            characters: %{character_id => UserCharacter.t()},
            character_battle_bonuses: %{
              character_id => CharacterBattleBonuses.t()
            },
            turn_character_actions: %{
              character_id => %{move: atom, attack: atom, target_id: integer}
            }
          }
  end

  @impl true
  def init(_) do
    state = %{battle_rooms: %{}}
    {:ok, state, {:continue, :init_active_battles}}
  end

  def init_battle(participants) do
    GenServer.call(__MODULE__, {:init_battle, participants})
  end

  def submit_action(battle_room_id, action_map) do
    GenServer.call(__MODULE__, {:submit_action, battle_room_id, action_map})
  end

  def check_all_submitted(battle_room_id) do
    GenServer.call(__MODULE__, {:check_all_submitted, battle_room_id})
  end

  def count_submitted(battle_room_id) do
    GenServer.call(__MODULE__, {:count_submitted, battle_room_id})
  end

  def finalize_turn(battle_room_id) do
    GenServer.call(__MODULE__, {:finalize_turn, battle_room_id})
  end

  def turn_seconds_left(battle_room_id) do
    GenServer.call(__MODULE__, {:turn_seconds_left, battle_room_id})
  end

  @impl true
  def handle_continue(:init_active_battles, state) do
    IO.inspect("init_active_battles")
    active_rooms = Battles.impl().get_all_active_rooms!()

    battle_rooms =
      active_rooms
      |> Enum.reduce(%{}, fn room, acc ->
        character_ids = room.participants |> Enum.map(& &1.user_character.id)
        bot_participants = Enum.filter(room.participants, & &1.is_bot)
        team_a_participants = Enum.filter(room.participants, & &1.team_a)
        team_b_participants = Enum.filter(room.participants, & &1.team_b)

        turn_character_actions =
          with_bot_actions(
            init_turn_character_actions_map(character_ids),
            bot_participants,
            team_a_participants,
            team_b_participants
          )

        battle_room_state = %RoomState{
          id: room.id,
          bot_participants: bot_participants,
          team_a_participants: team_a_participants,
          team_b_participants: team_b_participants,
          room: room,
          characters: build_characters_map(room.participants),
          character_battle_bonuses: build_character_battle_bonuses_map(room.participants),
          turn_character_actions: turn_character_actions,
          current_turn: room.current_turn,
          seconds_left: room.turn_duration_sec
        }

        Map.put(acc, room.id, battle_room_state)
      end)

    Process.send_after(self(), :tick_timer, 1000)

    {:noreply, %{state | battle_rooms: battle_rooms}}
  end

  @impl true
  def handle_call({:init_battle, human_participants}, _, state) do
    {:ok, room} = Battles.impl().get_open_room_or_create()
    IO.inspect("init_battle room #{room.id}")

    bot_participants =
      create_additional_bot_characters(
        room.max_participants,
        length(human_participants)
      )

    participants = human_participants ++ bot_participants

    character_ids = Enum.map(participants, & &1.user_character.id)
    {team_a_participants, team_b_participants} = define_teams(participants)

    Multi.new()
    |> multi_activate_room(room)
    |> multi_assign_team_and_room(room, participants, team_a_participants, team_b_participants)
    |> multi_broadcast_battle_room_assigned(participants)
    |> Repo.transaction()

    # reload room with registered participants
    room = Battles.impl().get_room!(room.id)

    turn_character_actions =
      init_turn_character_actions_map(character_ids)
      |> with_bot_actions(
        bot_participants,
        team_a_participants,
        team_b_participants
      )

    battle_room_state = %RoomState{
      id: room.id,
      bot_participants: bot_participants,
      team_a_participants: team_a_participants,
      team_b_participants: team_b_participants,
      room: room,
      characters: build_characters_map(participants),
      character_battle_bonuses: build_character_battle_bonuses_map(participants),
      turn_character_actions: turn_character_actions,
      seconds_left: room.turn_duration_sec
    }

    battle_rooms = Map.merge(state.battle_rooms, %{room.id => battle_room_state})

    {:reply, room.id, %{state | battle_rooms: battle_rooms}}
  end

  def handle_call(
        {:submit_action, battle_room_id,
         %{character_id: character_id, move: move, attack: attack, target_id: target_id}},
        _,
        state
      ) do
    IO.inspect("submit_action room #{battle_room_id}")
    battle_room = state.battle_rooms[battle_room_id]

    # turn_character_actions: %{<character_id> => %{move: move, attack: attack, target_id: target_id}}
    turn_character_actions =
      update_character_actions(
        battle_room.turn_character_actions,
        character_id,
        target_id,
        move,
        attack
      )

    new_state =
      update_battle_room_in_state(
        state,
        battle_room_id,
        turn_character_actions: turn_character_actions
      )

    {:reply, :ok, new_state}
  end

  def handle_call({:finalize_turn, battle_room_id}, _, state) do
    IO.inspect("finalize_turn room #{battle_room_id}")
    battle_room = state.battle_rooms[battle_room_id]
    turn_character_actions = battle_room.turn_character_actions

    character_ids = Map.keys(battle_room.characters)

    next_turn_character_actions =
      init_turn_character_actions_map(character_ids)
      |> with_bot_actions(
        battle_room.bot_participants,
        battle_room.team_a_participants,
        battle_room.team_b_participants
      )

    characters = update_characters_with_action(battle_room, turn_character_actions)
    battle_log = update_battle_log_with_actions(battle_room, turn_character_actions)

    Multi.new()
    |> multi_update_room_turn_and_log(battle_room.room, battle_log)
    |> multi_update_user_characters(battle_room.characters, characters)
    |> multi_update_eliminated_participants(battle_room.room.participants, characters)
    |> multi_end_battle_if_winner_exists(
      battle_room.room.participants,
      characters,
      battle_room.room
    )
    |> Repo.transaction()
    |> IO.inspect(label: "multi")

    room = Battles.impl().get_room!(battle_room_id)

    new_state =
      update_battle_room_in_state(
        state,
        battle_room_id,
        room: room,
        characters: characters,
        turn_character_actions: next_turn_character_actions,
        seconds_left: room.turn_duration_sec
      )

    {:reply, :ok, new_state}
  end

  def handle_call({:check_all_submitted, battle_room_id}, _, state) do
    battle_room = state.battle_rooms[battle_room_id]
    total_cnt = length(Map.keys(battle_room.characters))
    current_actions = Map.values(battle_room.turn_character_actions)

    submitted_cnt =
      Enum.reduce(current_actions, 0, fn %{move: move, attack: attack, target_id: target_id},
                                         count_acc ->
        if is_nil(move) and is_nil(attack) and is_nil(target_id),
          do: count_acc,
          else: count_acc + 1
      end)

    {:reply, submitted_cnt == total_cnt, state}
  end

  def handle_call({:count_submitted, battle_room_id}, _, state) do
    battle_room = state.battle_rooms[battle_room_id]
    current_actions = Map.values(battle_room.turn_character_actions)

    submitted_cnt =
      Enum.reduce(current_actions, 0, fn %{move: move, attack: attack, target_id: target_id},
                                         count_acc ->
        if is_nil(move) and is_nil(attack) and is_nil(target_id),
          do: count_acc,
          else: count_acc + 1
      end)

    {:reply, submitted_cnt, state}
  end

  def handle_call({:turn_seconds_left, battle_room_id}, _, state) do
    battle_room = state.battle_rooms[battle_room_id]

    {:reply, battle_room.seconds_left, state}
  end

  @impl true
  def handle_info(:tick_timer, state) do
    new_state =
      state.battle_rooms
      |> Map.values()
      |> Enum.filter(fn room_state -> room_state.room.winner_team == nil end)
      |> Enum.reduce(state, fn room_state, state_acc ->
        seconds_left = room_state.seconds_left - 1

        {:reply, all_submitted?, _} =
          handle_call({:check_all_submitted, room_state.id}, self(), state)

        turn_ended = seconds_left <= 0 or all_submitted?

        if turn_ended do
          IO.inspect("BattleRoomGs turn #{room_state.room.current_turn} ended")

          {:reply, :ok, new_state_acc} =
            handle_call({:finalize_turn, room_state.id}, self(), state_acc)

          new_state_acc
        else
          update_battle_room_in_state(
            state_acc,
            room_state.id,
            seconds_left: seconds_left
          )
        end
      end)

    Process.send_after(self(), :tick_timer, 1000)

    {:noreply, new_state}
  end

  def is_target_hit(attack, target_move) do
    (attack == :left && (target_move == :left or target_move == :forward_left)) ||
      (attack == :center && (target_move == :center or target_move == :forward_center)) ||
      (attack == :right && (target_move == :right or target_move == :forward_right))
  end

  defp multi_activate_room(multi, room) do
    Battles.impl().update_room_multi(multi, "activate_room", room, %{
      started_at: DateTime.utc_now(),
      awaiting_start: false
    })
  end

  defp multi_assign_team_and_room(
         multi,
         room,
         participants,
         team_a_participants,
         team_b_participants
       ) do
    Enum.reduce(
      participants,
      multi,
      fn participant, multi_acc ->
        Battles.impl().update_participant_multi(
          multi_acc,
          "assign_room_participant_#{participant.id}",
          participant,
          %{
            team_a: participant.id in Enum.map(team_a_participants, & &1.id),
            team_b: participant.id in Enum.map(team_b_participants, & &1.id),
            battle_room_id: room.id
          }
        )
      end
    )
  end

  defp multi_broadcast_battle_room_assigned(multi, participants) do
    Enum.reduce(
      participants,
      multi,
      fn %{id: participant_id}, mult_acc ->
        Multi.run(
          mult_acc,
          "notify_awaiting_participant_#{participant_id}",
          fn _, _ ->
            case Phoenix.PubSub.broadcast(
                   Tarragon.PubSub,
                   "awaiting_participant:#{participant_id}",
                   "battle_room_assigned"
                 ) do
              :ok ->
                {:ok, :success}

              error_tuple ->
                error_tuple
            end
          end
        )
      end
    )
  end

  def update_character_actions(turn_character_actions, character_id, target_id, move, attack) do
    move =
      case move do
        "move-left" -> :left
        "move-center" -> :center
        "move-right" -> :right
        "move-left-and-step" -> :forward_left
        "move-center-and-step" -> :forward_center
        "move-right-and-step" -> :forward_right
      end

    attack =
      case attack do
        "attack-left" -> :left
        "attack-center" -> :center
        "attack-right" -> :right
      end

    Map.put(
      turn_character_actions,
      character_id,
      %{move: move, attack: attack, target_id: target_id}
    )
  end

  defp with_bot_actions(
         turn_character_actions,
         bot_participants,
         team_a_participants,
         team_b_participants
       ) do
    bot_participants
    |> Enum.reduce(turn_character_actions, fn bot_participant, character_actions_acc ->
      opposite_team_participants =
        if bot_participant.team_a, do: team_b_participants, else: team_a_participants

      possible_options =
        Enum.map(opposite_team_participants, fn participant ->
          %{
            distance: 1,
            health: participant.user_character.current_health,
            target_id: participant.user_character.id
          }
        end)

      %{target_id: target_id, move: move, attack: attack} =
        Battles.impl().decide_bot_move(bot_participant.user_character.id, possible_options)

      update_character_actions(
        character_actions_acc,
        bot_participant.user_character_id,
        target_id,
        move,
        attack
      )
    end)
  end

  defp new_health(current_health, damage) do
    Enum.max([current_health - damage, 0])
  end

  defp update_characters_with_action(battle_room, turn_character_actions) do
    turn_character_actions
    |> Enum.filter(fn {_character_id, %{target_id: target_id}} -> !is_nil(target_id) end)
    |> Enum.reduce(
      battle_room.characters,
      fn {character_id, _action = %{attack: attack, target_id: target_id}}, characters_acc ->
        target = characters_acc[target_id]

        target_move =
          turn_character_actions[target_id][:move] ||
            turn_character_actions[target_id][:skip_turn_move]

        target =
          if is_target_hit(attack, target_move) do
            damage = battle_room.character_battle_bonuses[character_id].attack_bonus
            new_current_health = new_health(target.current_health, damage)
            %{target | current_health: new_current_health}
          else
            target
          end

        Map.put(characters_acc, target_id, target)
      end
    )
  end

  defp update_battle_log_with_actions(battle_room, turn_character_actions) do
    step_moves = [:forward_left, :forward_center, :forward_right]

    skipped_logs =
      turn_character_actions
      |> Enum.filter(fn {_, %{target_id: target_id, move: move, attack: attack}} ->
        is_nil(move) and is_nil(attack) and is_nil(target_id)
      end)
      |> Enum.map(fn {character_id, _action} ->
        character = battle_room.characters[character_id]

        %BattleLogEntry{
          event: :turn_skip,
          turn: battle_room.room.current_turn,
          attacker_id: character.id
        }
      end)
      |> IO.inspect()

    new_logs =
      turn_character_actions
      |> Enum.filter(fn {_, %{target_id: target_id, move: move}} ->
        !is_nil(target_id) || move in step_moves
      end)
      |> Enum.reduce([], fn {character_id,
                             _action = %{attack: attack, move: move, target_id: target_id}},
                            log_acc ->
        character = battle_room.characters[character_id]
        target = battle_room.characters[target_id]

        target_move =
          turn_character_actions[target_id][:move] ||
            turn_character_actions[target_id][:skip_turn_move]

        attacker_attack_bonus = battle_room.character_battle_bonuses[character_id].attack_bonus

        log_entry =
          cond do
            is_target_hit(attack, target_move) &&
                target.current_health <= attacker_attack_bonus ->
              %BattleLogEntry{
                event: :last_hit,
                turn: battle_room.room.current_turn,
                attacker_id: character.id,
                attacker_attack: "#{attack}",
                target_id: target.id,
                target_move: "#{target_move}",
                damage: battle_room.character_battle_bonuses[character_id].attack_bonus
              }

            is_target_hit(attack, target_move) ->
              %BattleLogEntry{
                event: :hit,
                turn: battle_room.room.current_turn,
                attacker_id: character.id,
                attacker_attack: "#{attack}",
                target_id: target.id,
                target_move: "#{target_move}",
                damage: attacker_attack_bonus
              }

            move in step_moves ->
              %BattleLogEntry{
                event: :step_closer,
                turn: battle_room.room.current_turn,
                attacker_id: character.id,
                attacker_attack: "#{attack}",
                attacker_move: "#{move}",
                damage: attacker_attack_bonus
              }

            true ->
              %BattleLogEntry{
                event: :miss,
                turn: battle_room.room.current_turn,
                attacker_id: character.id,
                attacker_attack: "#{attack}",
                target_id: target.id,
                target_move: "#{target_move}"
              }
          end

        log_acc ++ [log_entry]
      end)

    battle_room.room.logs ++ skipped_logs ++ new_logs
  end

  defp init_turn_character_actions_map(character_ids) do
    skip_turn_move = Enum.random([:left, :center, :right])

    character_ids
    |> Enum.map(fn character_id ->
      {character_id, %{move: nil, attack: nil, target_id: nil, skip_turn_move: skip_turn_move}}
    end)
    |> Enum.into(%{})
  end

  defp build_characters_map(participants) do
    Enum.map(participants, fn participant ->
      {participant.user_character.id, participant.user_character}
    end)
    |> Enum.into(%{})
  end

  defp create_additional_bot_characters(max_participants, human_participants_count) do
    if human_participants_count < max_participants do
      Enum.map(1..(max_participants - human_participants_count), fn _ ->
        bot_character = Battles.impl().create_bot_character()
        Battles.impl().create_participant(%{user_character_id: bot_character.id, is_bot: true})
      end)
    else
      []
    end
  end

  defp define_teams(participants) do
    len = round(length(participants) / 2)
    Enum.split(participants, len)
  end

  def build_character_battle_bonuses_map(participants) do
    Enum.map(participants, fn participant ->
      {participant.user_character.id,
       Battles.impl().build_character_bonuses(participant.user_character.id)}
    end)
    |> Enum.into(%{})
  end

  defp update_battle_room_in_state(state, battle_room_id, room_update_params) do
    room_update_params = Enum.into(room_update_params, %{})
    battle_room = state.battle_rooms[battle_room_id]
    updated_battle_room = Map.merge(battle_room, room_update_params)
    %{state | battle_rooms: Map.put(state.battle_rooms, battle_room_id, updated_battle_room)}
  end

  defp multi_update_room_turn_and_log(multi, room, battle_log) do
    Battles.impl().update_room_multi(
      multi,
      "update room turn and log",
      room,
      %{current_turn: room.current_turn + 1, logs: battle_log}
    )
  end

  defp multi_update_user_characters(multi, characters_before, characters_after) do
    Enum.reduce(characters_before, multi, fn {id, character}, multi_acc ->
      Accounts.impl().update_user_character_multi(
        multi_acc,
        "update character #{character.id}",
        character,
        Map.from_struct(characters_after[id])
      )
    end)
  end

  defp multi_update_eliminated_participants(multi, participants_before, characters_after) do
    alive_participants = Enum.filter(participants_before, &(!&1.eliminated))

    Enum.reduce(alive_participants, multi, fn participant, multi_acc ->
      Battles.impl().update_participant_multi(
        multi_acc,
        "eliminate_room_participant_#{participant.id}",
        participant,
        %{
          eliminated: characters_after[participant.user_character_id].current_health <= 0
        }
      )
    end)
  end

  defp multi_end_battle_if_winner_exists(multi, participants, characters, room) do
    winner_team = try_find_winner_team(participants, characters)

    if winner_team do
      Battles.impl().update_room_multi(multi, "end battle", room, %{
        ended_at: DateTime.utc_now(),
        winner_team: winner_team
      })
    else
      multi
    end
  end

  defp try_find_winner_team(participants, characters) do
    remaining_participants =
      participants
      |> Enum.filter(&(&1.eliminated == false))
      |> Enum.filter(&(characters[&1.user_character_id].current_health >= 1))

    cond do
      remaining_participants == [] ->
        :draw

      Enum.all?(remaining_participants, & &1.team_a) ->
        :team_a

      Enum.all?(remaining_participants, & &1.team_b) ->
        :team_b

      true ->
        nil
    end
  end
end
