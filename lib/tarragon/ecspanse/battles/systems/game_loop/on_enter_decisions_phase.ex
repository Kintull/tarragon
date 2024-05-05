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
  alias Tarragon.Ecspanse.Battles.Components.Actions
  alias Tarragon.Ecspanse.Battles.Encumbering
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.decisions_phase

  def run(
        %EcspanseStateMachine.Events.StateChanged{
          entity_id: entity_id,
          to: @to_state
        },
        _frame
      ) do
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
      Entities.Battle.list_living_combatants(battle_entity)
      |> Enum.filter(&Ecspanse.Query.has_component?(&1, Components.BotBrain))

    Enum.each(bot_entities, fn bot_entity ->
      with {:ok, _bot_brain} <- Components.BotBrain.fetch(bot_entity) do
        available_action_entities = Lookup.list_children(bot_entity, Components.AvailableAction)
        chosen_action = BotAi.choose_actions(bot_entity, available_action_entities)

        unless chosen_action == nil, do: Api.schedule_available_action(chosen_action.id)

        Api.lock_intentions(bot_entity.id)
      end
    end)
  end

  defp update_living_combatants(battle_entity) do
    living_combatants = Entities.Battle.list_living_combatants(battle_entity)

    update_encumbrances(living_combatants)
    set_waiting_for_intentions(living_combatants)
    increment_action_points(living_combatants)

    spawn_available_actions(battle_entity, living_combatants)
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

  defp map_set_put_if(map_set, condition, value) do
    if condition do
      MapSet.put(map_set, value)
    else
      map_set
    end
  end

  defp spawn_available_actions(battle_entity, combatant_entities)
       when is_list(combatant_entities) do
    Enum.each(combatant_entities, &spawn_available_actions(battle_entity, &1))
  end

  defp spawn_available_actions(battle_entity, %Ecspanse.Entity{} = combatant_entity) do
    with {:ok, {frag_grenades, main_weapon, profession, smoke_grenades}} <-
           Ecspanse.Query.fetch_components(
             combatant_entity,
             {Components.FragGrenade, Components.MainWeapon, Components.Profession,
              Components.SmokeGrenade}
           ) do
      enemies_by_distance_from_me =
        Entities.Battle.enemies_by_distance_from_me(battle_entity, combatant_entity)

      # |> IO.inspect(label: "enemies_by_distance_from_me")

      enemies_in_main_weapon_range =
        enemies_by_distance_from_me
        |> Map.filter(fn {k, _v} -> k <= main_weapon.range end)
        |> Map.values()
        |> List.flatten()

      any_enemies_in_frag_range =
        Enum.any?(Map.keys(enemies_by_distance_from_me), &(&1 <= 2))

      shortest_distance_to_enemy = Enum.min(Map.keys(enemies_by_distance_from_me))

      im_in_range = Entities.Battle.am_i_in_range_of_enemy?(battle_entity, combatant_entity)

      actions =
        MapSet.new()
        |> map_set_put_if(
          im_in_range,
          case profession.type do
            :sniper -> {Actions.Dodge, [action_point_cost: 2]}
            _ -> {Actions.Dodge, [action_point_cost: 1]}
          end
        )
        |> map_set_put_if(
          shortest_distance_to_enemy > 1,
          case {profession.type, main_weapon.deployed} do
            {:pistolero, _} -> {Actions.Movement.Advance, []}
            {_, false} -> {Actions.Movement.Advance, [action_point_cost: 1]}
            {_, _} -> {Actions.Movement.Advance, [action_point_cost: 3]}
          end
        )
        |> map_set_put_if(
          shortest_distance_to_enemy > 2 and profession.type == :pistolero,
          {Actions.Movement.Rush, []}
        )
        |> map_set_put_if(
          main_weapon.packable && main_weapon.deployed,
          {Actions.Weapon.PackWeapon, []}
        )
        |> map_set_put_if(
          main_weapon.packable && !main_weapon.deployed,
          {Actions.Weapon.DeployWeapon, []}
        )
        |> map_set_put_if(
          frag_grenades.count > 0 && any_enemies_in_frag_range,
          {Actions.Grenades.TossFragGrenade, []}
        )
        |> map_set_put_if(
          smoke_grenades.count > 0 and im_in_range,
          {Actions.Grenades.PopSmokeGrenade, []}
        )

      actions =
        enemies_in_main_weapon_range
        |> Enum.reduce(actions, fn enemy, acc ->
          with {:ok, brand} <- Components.Brand.fetch(enemy) do
            acc
            |> map_set_put_if(
              main_weapon.deployed,
              {Actions.Shooting.Shoot, [target_entity_id: enemy.id, name: "Shoot #{brand.name}"]}
            )
            |> map_set_put_if(
              main_weapon.deployed && profession.type == :pistolero,
              {Actions.Shooting.DoubleTap,
               [target_entity_id: enemy.id, name: "Double Tap #{brand.name}"]}
            )
          end
        end)

      actions
      |> Enum.map(fn aa_spec ->
        Entities.AvailableAction.new(combatant_entity, aa_spec)
      end)
      |> Ecspanse.Command.spawn_entities!()
    end
  end
end
