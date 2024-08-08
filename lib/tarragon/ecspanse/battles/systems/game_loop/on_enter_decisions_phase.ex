defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterDecisionsPhase do
  @moduledoc """
  * Increments turn counter
  * Increments Action Points
  * Sets Waiting for intentions
  * Spawns Available Actions
  """

  alias Tarragon.Ecspanse.Battles.Api
  alias Tarragon.Ecspanse.Battles.BotAi
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Encumbering
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  require Logger

  @to_state @state_names.decisions_phase

  def run(
        %EcspanseStateMachine.Events.StateChanged{
          entity_id: entity_id,
          to: @to_state
        },
        _frame
      ) do
    Logger.debug("OnEnterDecisionsPhase #{entity_id}")

    with {:ok, battle_entity} <- Ecspanse.Query.fetch_entity(entity_id) do
      increment_turn_counter(battle_entity)

      update_living_combatants(battle_entity)

      process_bots(battle_entity)
    end
  end

  def run(_, _), do: :ok

  def increment_turn_counter(battle_entity) do
    with {:ok, battle_component} <- Components.Battle.fetch(battle_entity) do
      Ecspanse.Command.update_component!(battle_component,
        turn: battle_component.turn + 1
      )
    end
  end

  defp process_bots(battle_entity) do
    bot_entities =
      Entities.BattleEntity.list_living_combatants(battle_entity)
      |> Enum.filter(&Ecspanse.Query.has_component?(&1, Components.BotBrain))

    Enum.each(bot_entities, fn bot_entity ->
      with {:ok, _bot_brain} <- Components.BotBrain.fetch(bot_entity) do
        available_action_entities = Lookup.list_children(bot_entity, Components.ActionState)
        chosen_action = BotAi.choose_actions(bot_entity, available_action_entities)

        unless chosen_action == nil, do: Api.schedule_available_action(chosen_action.id)

        Api.lock_intentions(bot_entity.id)
      end
    end)
  end

  defp update_living_combatants(battle_entity) do
    living_combatants = Entities.BattleEntity.list_living_combatants(battle_entity)

    update_encumbrances(living_combatants)
    set_waiting_for_intentions(living_combatants)
    increment_action_points(living_combatants)

#    spawn_available_actions(battle_entity, living_combatants)
    update_available_attack_target_options(battle_entity, living_combatants)
    update_available_actions(living_combatants)
  end

  defp increment_action_points(combatant_entities) do
    combatant_entities
    |> Enum.map(fn ce ->
      with {:ok, {combatant, action_points}} <-
             Ecspanse.Query.fetch_components(ce, {Components.Combatant, Components.ActionPoints}) do
        {action_points,
         current: min(action_points.current + combatant.action_points_per_turn, action_points.max)}
      end
    end)
    |> Ecspanse.Command.update_components!()
  end

  defp set_waiting_for_intentions(combatant_entities) do
    combatant_entities
    |> Enum.map(fn ce ->
      with {:ok, combatant} <- Components.Combatant.fetch(ce) do
        {combatant, waiting_for_intentions: true}
      end
    end)
    |> Ecspanse.Command.update_components!()
  end

  defp update_encumbrances(combatant_entities) do
    combatant_entities
    |> Enum.map(fn ce ->
      with {:ok, combatant} <- Components.Combatant.fetch(ce) do
        {combatant, encumbrance: Encumbering.encumber(combatant)}
      end
    end)
    |> Ecspanse.Command.update_components!()
  end

#  defp map_set_put_if(map_set, condition, value) do
#    if condition do
#      MapSet.put(map_set, value)
#    else
#      map_set
#    end
#  end

#  defp spawn_available_actions(battle_entity, combatant_entities)
#       when is_list(combatant_entities) do
#    Enum.each(combatant_entities, &spawn_available_actions(battle_entity, &1))
#  end

#  defp spawn_available_actions(battle_entity, %Ecspanse.Entity{} = combatant_entity) do
#    with {:ok, {frag_grenades, main_weapon, profession, smoke_grenades}} <-
#           Ecspanse.Query.fetch_components(
#             combatant_entity,
#             {Components.FragGrenade, Components.MainWeapon, Components.Profession,
#              Components.SmokeGrenade}
#           ) do
#      enemies_by_distance_from_me =
#        Entities.BattleEntity.enemies_by_distance_from_me(battle_entity, combatant_entity)
#
#      enemies_in_main_weapon_range =
#        enemies_by_distance_from_me
#        |> Map.filter(fn {k, _v} -> k <= main_weapon.range end)
#        |> Map.values()
#        |> List.flatten()
#
#      any_enemies_in_frag_range =
#        Enum.any?(Map.keys(enemies_by_distance_from_me), &(&1 <= 2))
#
#      shortest_distance_to_enemy = Enum.min(Map.keys(enemies_by_distance_from_me))
#
#      im_in_range = Entities.BattleEntity.am_i_in_range_of_enemy?(battle_entity, combatant_entity)
#
#      actions =
#        MapSet.new()
#        |> map_set_put_if(
#          im_in_range,
#          case profession.type do
#            :sniper -> {Actions.Dodge, [action_point_cost: 2]}
#            _ -> {Actions.Dodge, [action_point_cost: 1]}
#          end
#        )
#        |> map_set_put_if(
#          true,
#          case {profession.type, main_weapon.deployed} do
#            {:pistolero, _} -> {Actions.Movement.Advance, []}
#            {_, false} -> {Actions.Movement.Advance, [action_point_cost: 1]}
#            {_, _} -> {Actions.Movement.Advance, [action_point_cost: 3]}
#          end
#        )
#        |> map_set_put_if(
#          shortest_distance_to_enemy > 2 and profession.type == :pistolero,
#          {Actions.Movement.Rush, []}
#        )
#        |> map_set_put_if(
#          main_weapon.packable && main_weapon.deployed,
#          {Actions.Weapon.PackWeapon, []}
#        )
#        |> map_set_put_if(
#          main_weapon.packable && !main_weapon.deployed,
#          {Actions.Weapon.DeployWeapon, []}
#        )
#        |> map_set_put_if(
#          frag_grenades.count > 0 && any_enemies_in_frag_range,
#          {Actions.Grenades.TossFragGrenade, []}
#        )
#        |> map_set_put_if(
#          smoke_grenades.count > 0 and im_in_range,
#          {Actions.Grenades.PopSmokeGrenade, []}
#        )
#
#      actions =
#        enemies_in_main_weapon_range
#        |> Enum.reduce(actions, fn enemy, acc ->
#          with {:ok, brand} <- Components.Brand.fetch(enemy) do
#            acc
#            |> map_set_put_if(
#              main_weapon.deployed,
#              {Actions.Shooting.Shoot, [target_entity_id: enemy.id, name: "Shoot #{brand.name}"]}
#            )
#            |> map_set_put_if(
#              main_weapon.deployed && profession.type == :pistolero,
#              {Actions.Shooting.DoubleTap,
#               [target_entity_id: enemy.id, name: "Double Tap #{brand.name}"]}
#            )
#          end
#        end)
#
#      actions
#      |> Enum.map(fn aa_spec ->
#        Entities.AvailableAction.new(combatant_entity, aa_spec)
#      end)
#      |> Ecspanse.Command.spawn_entities!()
#    end
#  end

  defp update_available_attack_target_options(battle_entity, combatant_entities) do
    Enum.each(combatant_entities, &(update_available_attack_target_option(battle_entity, &1)))
  end

  defp update_available_attack_target_option(battle_entity, combatant_entity) do
    results = Ecspanse.Query.select({Ecspanse.Entity, Components.AttackTargetOption},
                for_entities: [combatant_entity]
              )
              |> Ecspanse.Query.stream()
              |> Enum.to_list()

    # Remove old target options
    Enum.each(results, fn {_, old_target_option} -> Ecspanse.Command.remove_component!(old_target_option) end)

    {:ok, main_weapon} = Components.MainWeapon.fetch(combatant_entity)

    enemies_by_distance_from_me =
      Entities.BattleEntity.enemies_by_distance_from_me(battle_entity, combatant_entity)

    enemies_in_main_weapon_range =
      enemies_by_distance_from_me
      |> Map.filter(fn {k, _v} -> k <= main_weapon.range end)
      |> Map.values()
      |> List.flatten()

    # Add new target options
    enemies_in_main_weapon_range
    |> Enum.each(fn enemy ->
      with {:ok, enemy_combatant} <- Components.Combatant.fetch(enemy) do
        {:ok, c} = Components.Combatant.fetch(combatant_entity)
        IO.inspect("center user: #{c.user_id}, enemy: #{enemy_combatant.user_id}", label: "enemies_in_main_weapon_range combatant.user_id")
        Ecspanse.Command.add_component!(combatant_entity, {Components.AttackTargetOption, [user_id: enemy_combatant.user_id, combatant_entity_id: enemy.id]})
      end
    end)
  end

  defp update_available_actions(combatant_entities) when is_list(combatant_entities) do
      Enum.each(combatant_entities, fn ce -> update_available_actions(ce) end)
  end

  defp update_available_actions(combatant_entity) do
    # get children (actions) of combatant_entity
    # update children availability based on the action points (on combatant component)
    with {:ok, action_points} <- Ecspanse.Query.fetch_component(combatant_entity, Components.ActionPoints) do
      results = Ecspanse.Query.select({Ecspanse.Entity, Components.ActionState},
        for_children_of: [combatant_entity]
      )
      |> Ecspanse.Query.stream()
      |> Enum.to_list()

      Enum.map(results, fn {action_entity, action_state} ->
        {:ok, action} = Ecspanse.Query.fetch_tagged_component(action_entity, [:action])

        Ecspanse.Command.update_component!(action_state,
          is_available: action.action_point_cost <= action_points.current,
          is_scheduled: false
        )
      end)
   end
  end
end
