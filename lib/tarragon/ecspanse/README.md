Entity map

[E]Battle
    - [C]Battle [game_id: game_id, max_turns: max_turns, name: name]
    - [C]EcspanseStateMachine [auto_start: false]

    - [E]Team
        - [C] Team (tag) tags: [:team]
        - [C] Brand [name, color, icon]
        - [E] Combatant

[E]Combatant
    - [E]AvailableAction
        - [C] AvailableAction (tag)
        - [C] Actions.Template [steps, action_group, icon, action_point_cost] tags: [:action]

    - [E]ScheduledAction
        - [C] ScheduledAction (tag)
        - [C] Actions.Template [steps, action_group, icon, action_point_cost] tags: [:action]

    - [C] ActionPoints [current, max]
    - [C] Brand [name, icon, color]
    - [C] Combatant [user_id, action_points_per_turn, encumbrance, waiting_for_intentions], tags: [:combatant]
    - [C] Direction [x, y]
    - [C] Position [x, y]
    - [C] Health [current, max]
    - [C] Profession [name, type], tags: [:profession]
    - [C] SmokeGrenade [count, encumberance, icon, name, radius, range, type], tags: [:grenade]
    - [C] FragGrenade [count, damage, icon, name, radius, range, type], tags: [:grenade]
    - [C] MainWeapon [type, name, range, projectiles_per_shot, damage_per_projectile, packed_encumbrance, deployed_encumbrance, encumbrance, packable, deployed], tags: [:main_weapon]
    - [C] BotBrain (tag)


Tarragon Entities used for starting a battle:

UserCharacter
Profession
GearItem (CharacterItem)
BattleRoom
    BattleRoomParticipant


ECS Entities for BattleViewV3:

e battle
    c battle
        - battle_room_id
        - turn
    c state_machine
    e team
        c team
            - name (id)
            - score
        e combatant
            c combatant
                - character_id
                - ended_turn
                - encumbrance
            c action
                - action_id
                - is_available
                - is_scheduled
                - energy_cost
            c scheduled_action
                - action_id
            c energy
                - max
                - current
                - regen_per_turn
            c health
                - max
                - current
            c position
                - x
                - y
            c main_weapon
                - name
                - range
                - projectiles_per_shot
                - damage_per_projectile
                - packed_encumbrance
                - deployed_encumbrance
                - encumbrance
                - packable
                - deployed
            c frag_grenade
                - count
                - damage
                - name
                - range
                - radius
            c smoke_grenade
                - count
                - name
                - range
                - radius






