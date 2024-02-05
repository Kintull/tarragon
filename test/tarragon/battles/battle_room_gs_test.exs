defmodule Tarragon.Battles.BattleRoomTest do
  use Tarragon.DataCase

  alias Tarragon.Battles.BattleRoom

  import Tarragon.Factory

  setup do
    character1 =
      build(:user_character, max_health: 30, current_health: 30) |> with_full_equipment()

    character2 =
      build(:user_character, max_health: 32, current_health: 32) |> with_full_equipment()

    character3 =
      build(:user_character, max_health: 30, current_health: 30) |> with_full_equipment()

    character4 =
      build(:user_character, max_health: 30, current_health: 30) |> with_full_equipment()

    Hammox.stub(Tarragon.Battles.impl(), :build_character_bonuses, fn id ->
      %{
        character_id: id,
        attack_bonus: 31,
        defence_bonus: 10,
        health_bonus: 10,
        max_health: 20,
        range_bonus: 10
      }
    end)

    [character_structs: [character1, character2, character3, character4]]
  end

  def init_state do
    {:ok, state, _} = BattleRoom.init([])
    {:noreply, state} = BattleRoom.handle_continue(:init_active_battles, state)
    state
  end

  test "init room", %{character_structs: character_structs} do
    [%{id: id1}, %{id: id2}, %{id: id3}, %{id: id4}] = character_structs

    assert {:reply, battle_room_id, new_state} =
             BattleRoom.handle_call({:init_battle, character_structs}, self(), init_state())

    assert %{turn: turn, characters: _, turn_actions: turn_actions} =
             new_state.battle_rooms[battle_room_id]

    assert turn == 1
    assert Map.keys(turn_actions) == [1]

    assert turn_actions[1] == %{
             id1 => %{attack: nil, move: nil, target_id: nil},
             id2 => %{attack: nil, move: nil, target_id: nil},
             id3 => %{attack: nil, move: nil, target_id: nil},
             id4 => %{attack: nil, move: nil, target_id: nil}
           }
  end

  test "submit action", %{character_structs: character_structs} do
    [%{id: id1}, %{id: id2}, %{id: id3}, %{id: id4}] = character_structs

    {_, battle_room_id, state} =
      BattleRoom.handle_call({:init_battle, character_structs}, self(), init_state())

    assert {:reply, :ok, new_state} =
             submit_action(id1, id2, "left", "left", battle_room_id, state)

    assert %{turn: 1, characters: _, turn_actions: turn_actions} =
             new_state.battle_rooms[battle_room_id]

    assert turn_actions[1] == %{
             id1 => %{attack: :left, move: :left, target_id: id2},
             id2 => %{attack: nil, move: nil, target_id: nil},
             id3 => %{attack: nil, move: nil, target_id: nil},
             id4 => %{attack: nil, move: nil, target_id: nil}
           }

    assert {:reply, :ok, new_state} =
             submit_action(id3, id4, "center", "center", battle_room_id, new_state)

    assert %{turn: 1, characters: _, turn_actions: turn_actions} =
             new_state.battle_rooms[battle_room_id]

    assert turn_actions[1] == %{
             id1 => %{attack: :left, move: :left, target_id: id2},
             id2 => %{attack: nil, move: nil, target_id: nil},
             id3 => %{attack: :center, move: :center, target_id: id4},
             id4 => %{attack: nil, move: nil, target_id: nil}
           }
  end

  def submit_action(from, to, attack, move, battle_room_id, state) do
    BattleRoom.handle_call(
      {:submit_action, battle_room_id,
       %{character_id: from, move: move, attack: attack, target_id: to}},
      self(),
      state
    )
  end

  test "submit action all move/attack options", %{character_structs: character_structs} do
    [%{id: id1}, %{id: id2}, _, _] = character_structs

    {_, battle_room_id, state} =
      BattleRoom.handle_call({:init_battle, character_structs}, self(), init_state())

    options = %{
      {"left", "left"} => %{attack: :left, move: :left, target_id: id2},
      {"center", "left"} => %{attack: :center, move: :left, target_id: id2},
      {"right", "left"} => %{attack: :right, move: :left, target_id: id2},
      {"left", "center"} => %{attack: :left, move: :center, target_id: id2},
      {"left", "right"} => %{attack: :left, move: :right, target_id: id2},
      {"left", "left-and-step"} => %{attack: :left, move: :forward_left, target_id: id2},
      {"left", "center-and-step"} => %{attack: :left, move: :forward_center, target_id: id2},
      {"left", "right-and-step"} => %{attack: :left, move: :forward_right, target_id: id2}
    }

    for {input, output} <- options do
      {:reply, :ok, state} =
        submit_action(id1, id2, elem(input, 0), elem(input, 1), battle_room_id, state)

      battle_room = state.battle_rooms[battle_room_id]
      assert battle_room.turn_actions[1][id1] == output
    end
  end

  test "finalize turn calculation", %{character_structs: character_structs} do
    [%{id: id1}, %{id: id2}, %{id: id3}, %{id: id4}] = character_structs

    {_, battle_room_id, state} =
      BattleRoom.handle_call({:init_battle, character_structs}, self(), init_state())

    {:reply, :ok, state} = submit_action(id1, id2, "center", "center", battle_room_id, state)
    {:reply, :ok, state} = submit_action(id2, id1, "center", "center", battle_room_id, state)

    {:reply, characters, state} =
      BattleRoom.handle_call({:finalize_turn, battle_room_id}, self(), state)

    battle_room = state.battle_rooms[battle_room_id]
    %{^id1 => pl1, ^id2 => pl2} = characters
    assert pl1.current_health == 0
    assert pl2.current_health == 1
    assert battle_room.turn == 2

    assert battle_room.turn_actions[1] == %{
             id1 => %{attack: :center, move: :center, target_id: id2},
             id2 => %{attack: :center, move: :center, target_id: id1},
             id3 => %{attack: nil, move: nil, target_id: nil},
             id4 => %{attack: nil, move: nil, target_id: nil}
           }

    assert battle_room.turn_actions[2] == %{
             id1 => %{attack: nil, move: nil, target_id: nil},
             id2 => %{attack: nil, move: nil, target_id: nil},
             id3 => %{attack: nil, move: nil, target_id: nil},
             id4 => %{attack: nil, move: nil, target_id: nil}
           }

    assert battle_room.battle_log == [
             %{attacker_id: id1, damage: 31, target_id: id2, turn: 1, type: :hit},
             %{attacker_id: id2, damage: 31, target_id: id1, turn: 1, type: :last_hit}
           ]
  end

  test "target hit" do
    assert true == BattleRoom.is_target_hit(:left, :left)
    assert false == BattleRoom.is_target_hit(:left, :center)
    assert false == BattleRoom.is_target_hit(:left, :right)

    assert true == BattleRoom.is_target_hit(:left, :forward_left)
    assert false == BattleRoom.is_target_hit(:left, :forward_center)
    assert false == BattleRoom.is_target_hit(:left, :forward_right)

    assert false == BattleRoom.is_target_hit(:center, :left)
    assert true == BattleRoom.is_target_hit(:center, :center)
    assert false == BattleRoom.is_target_hit(:center, :right)

    assert false == BattleRoom.is_target_hit(:center, :forward_left)
    assert true == BattleRoom.is_target_hit(:center, :forward_center)
    assert false == BattleRoom.is_target_hit(:center, :forward_right)

    assert false == BattleRoom.is_target_hit(:right, :left)
    assert false == BattleRoom.is_target_hit(:right, :center)
    assert true == BattleRoom.is_target_hit(:right, :right)

    assert false == BattleRoom.is_target_hit(:right, :forward_left)
    assert false == BattleRoom.is_target_hit(:right, :forward_center)
    assert true == BattleRoom.is_target_hit(:right, :forward_right)
  end
end
