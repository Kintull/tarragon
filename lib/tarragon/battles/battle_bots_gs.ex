defmodule Tarragon.Battles.BattleBots do
  use GenServer

  alias Tarragon.Battles

  defmodule Bot do
    defstruct [:bot_id, :battle_room_id, :character]
  end

  def decide_bot_move(bot_id, attack_options) do
    GenServer.call(__MODULE__, {:decide_move, bot_id, attack_options})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    {:ok, %{bots: %{}}, {:continue, :init_bots}}
  end

  def handle_continue(:init_bots, state) do
    {:noreply, state}
  end

  def create_new_bot do
    character = Battles.impl().create_bot_character()
    %Bot{bot_id: character.id, battle_room_id: nil, character: character}
  end

  def handle_call({:init_bot, battle_room_id}, _, state) do
    available_bot =
      Enum.find(Map.values(state.bots), create_new_bot(), fn bot ->
        bot.battle_room_id == nil
      end)

    bot = %Bot{available_bot | battle_room_id: battle_room_id}

    {:reply, {bot.bot_id, bot.character},
     %{state | bots: Map.merge(state.bots, %{bot.bot_id => bot})}}
  end

  def handle_call({:decide_move, _bot_id, attack_options}, _, state) do
    #    attack_options = [
    #      %{distance: 1, health: 10, target_id: 1},
    #      %{distance: 2, health: 20, target_id: 2},
    #      %{distance: 3, health: 30, target_id: 3}
    #    ]
    %{target_id: target_id} = Enum.random(attack_options)
    move = Enum.random(["move-left", "move-center", "move-right"])
    attack = Enum.random(["attack-left", "attack-center", "attack-right"])
    {:reply, %{target_id: target_id, move: move, attack: attack}, state}
  end

  def handle_call({:take_hit, bot_id, damage}, _, state) do
    bot = state.bots[bot_id]
    new_health = max(bot.character.current_health - damage, 0)
    updated_character = %{bot.character | current_health: new_health}

    new_bot = %Bot{bot | character: updated_character}

    new_bots = Map.merge(state.bots, %{bot_id => new_bot})

    {:reply, :ok, %{state | bots: new_bots}}
  end

  def handle_call({:end_battle, bot_id}, _, state) do
    bot = state.bots[bot_id]
    character = bot.character

    bot = %Bot{
      bot_id: bot_id,
      battle_room_id: nil,
      character: %{character | current_health: character.max_health}
    }

    {:reply, :ok, %{state | bots: Map.merge(state.bots, %{bot_id => bot})}}
  end
end
