# Tarragon

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Optimizing loading pictures https://css-tricks.com/the-blur-up-technique-for-loading-background-images/
* Passing Viewport dimensions on mount https://gist.github.com/cblavier/0e227de6fd1dfa00814b88642cdcb2a9

## Character backpack relationships

character has_one primary_weapon_slot(item_container fk: primary_weapon_slot_id);
item_container(primary_weapon_slot) belongs_to character (fk: primary_weapon_slot_id)
item_container has_many character_items;
character_item belongs_to item_container (fk: item_container_id)
character_item belongs_to game_item (fk: game_item_id)

## Battle logic with bots

* Lobby
    - "search_for_battles"
        * create participant record (without battle_room_id)
        * subscribe to "awaiting_participant:#{participant.id}" (PubSub channel)

    - "stop_searching_for_battles"
        * delete participant record
        * unsubscribe to "awaiting_participant:#{participant.id}" (PubSub channel)

    - "battle_room_assigned" (PubSub channel)
        * unsubscribe to "awaiting_participant:#{participant.id}" (PubSub channel)
        * redirect to BattleScreen

* BattleBots GenServer
    - {:init_bot, battle_room_id} - load bot character in memory (returns character_id)
    - {:take_hit, bot_id, damage}
    - {:decide_move, bot_id, attack_options}
        * attack_options: [%{distance: 1, health: 10, target_id: 1}]
    - {:end_battle, bot_id}

* LobbyTracker GenServer
    - loops and queries if there are any participants (without battle_room_id assigned)
        - if so, start a battle
        - add battle_room_id to participants
        - add team_a/team_b to participants
        - push "battle_room_assigned" to "awaiting_participant:#{participant.id}"

* BattleRoom GenServer
    - {:init_battle, character_structs} -> battle_room_id initializes actions/logs structure for the battle
        * also submit actions for bots
    - {:submit_action, battle_room_id, %{character_id: character_id, move: move, attack: attack, target_id: target_id}}
    - {:finalize_turn, battle_room_id}
        * also submit actions for bots

* BattleScreen LiveView
    - mount - read battle_room from db, assign ally and enemy teams
        - assign current_user_id
        - init timer check every 1 second
    - remember move
    - remember attack
    - submit action (human)
    - timer check
        - if all submitted - call BattleRoom.finalize_turn
        - if not - timer check in 1 second

### Flow

* Lobby view
* User clicks "Join Battle"
    - create Participant for the user (without battle_room_id)
    - PubSub subscribes to `awaiting_participant:#{participant.id}` channel

* LobbyTracker
    - check_awaiting_participants On TimerTick (`check_awaiting_participants`)
        * checks if there are any participants without `battle_room_id`
        * group participants by `max_participants`
        * for every participant group
            - call `BattleRoom.init_battle` with human characters + bots

* BattleRoom
    - handle_call `BattleRoom.init_battle(characters, rest_with_bots: true)`
        * create `Room`, `awaiting_start: false`
        * create additional Bot characters (`BattleBots.init_bot`)
        * assign `battle_room_id`, `team_a`/`team_b `to participants
        * broadcasts PubSub `"battle_room_assigned"` to `"awaiting_participant:#{participant.id}"`
        * create actions/logs structure for the battle
        * submit actions for bots `BattleBot.decide_move`

* Lobby View
    - on "battle_room_assigned"
        * unsubscribe from `awaiting_participant:#{participant.id}` channel
        * redirect to `BattleScreen`

* BattleScreen
    - mount
        * load participants/characters from room record
        * load timer settings from room record
    - accept move, attack
    - submit action (not allowed to edit after submit)
        * submit action to `BattleRoom.submit_action`
    - on TimerTick
        * check if all human participants submitted actions
        * TODO: call `BattleRoom.check_all_submitted()`
        * if all submitted - call `BattleRoom.finalize_turn`
            * else: check again in 1 second
        * check if current player is dead
            * if so - set a variable `dead` to true, allow user to quit the battle
        * check if all players from one team are dead
            * do cleanup
            * TODO: call `BattleRoom.end_battle`

* BattleRoom
    - finalize_turn:
        * call `BattleBot.decide_move` for all bots
        * call `BattleRoom.finalize_turn` for all bots

    - end_battle:
        * Call `BattleBot.end_battle()` for all bots
        * Update Room record with `ended_at`
        
