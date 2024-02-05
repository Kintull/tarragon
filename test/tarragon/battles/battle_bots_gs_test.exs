defmodule Tarragon.BattleBotsTest do
  use Tarragon.DataCase
  alias Tarragon.Battles.BattleBots

  setup do
    Hammox.stub(
      Tarragon.Inventory.impl(),
      :create_character_item,
      &Tarragon.Inventory.Impl.create_character_item(&1)
    )

    Hammox.stub(Tarragon.Inventory.impl(), :list_items, fn ->
      Tarragon.Inventory.Impl.list_items()
    end)

    Hammox.stub(
      Tarragon.Inventory.impl(),
      :create_container,
      &Tarragon.Inventory.Impl.create_container(&1)
    )

    Hammox.stub(
      Tarragon.Accounts.impl(),
      :create_user_character,
      &Tarragon.Accounts.Impl.create_user_character(&1)
    )

    Hammox.stub(Tarragon.Accounts.impl(), :create_user, &Tarragon.Accounts.Impl.create_user(&1))
    :ok
  end

  describe "battle_bot" do
    test "init new bot" do
      battle_room_id = 1
      {:ok, init_state} = BattleBots.init([])

      {:reply, {bot_id, _character}, state} =
        BattleBots.handle_call({:init_bot, battle_room_id}, self(), init_state)

      assert %BattleBots.Bot{
               bot_id: ^bot_id,
               battle_room_id: _battle_room_id,
               character: %Tarragon.Accounts.UserCharacter{}
             } = state.bots[bot_id]
    end

    test "bot takes hit" do
      battle_room_id = 1
      {:ok, state} = BattleBots.init([])

      {:reply, {bot_id, _character}, state} =
        BattleBots.handle_call({:init_bot, battle_room_id}, self(), state)

      {:reply, _, state} = BattleBots.handle_call({:take_hit, bot_id, 101}, self(), state)

      assert %BattleBots.Bot{
               bot_id: ^bot_id,
               battle_room_id: _battle_room_id,
               character: %Tarragon.Accounts.UserCharacter{
                 current_health: current_health,
                 max_health: max_health
               }
             } = state.bots[bot_id]

      assert max_health == 100
      assert current_health == 0
    end

    test "bot decides on action" do
      battle_room_id = 1
      {:ok, state} = BattleBots.init([])

      {:reply, {bot_id, _character}, state} =
        BattleBots.handle_call({:init_bot, battle_room_id}, self(), state)

      attack_options = [
        %{distance: 1, health: 10, target_id: 1},
        %{distance: 2, health: 20, target_id: 2}
      ]

      {:reply, target_id, _state} =
        BattleBots.handle_call({:decide_move, bot_id, attack_options}, self(), state)

      assert target_id in [1, 2]
    end
  end
end
