defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterDecisionsPhase do
  @moduledoc """
  * Increments turn counter
  * Increments Action Points
  * Sets Waiting for intentions
  * Spawns Available Actions
  """
  alias Tarragon.Ecspanse.Battles.Components.Actions
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  def run(
        %EcspanseStateMachine.Events.StateChanged{
          entity_id: entity_id,
          to: "Decisions Phase"
        },
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Query.fetch_entity(entity_id) do
      increment_turn_counter(battle_entity)

      update_living_combatants(battle_entity)
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

  defp update_living_combatants(battle_entity) do
    living_combatants = Entities.Battle.list_living_combatants(battle_entity)

    # set waiting for intentions to each combatant
    living_combatants
    |> Enum.each(fn ce ->
      increment_action_points(ce)
      set_waiting_for_intentions(ce)
      spawn_available_actions(ce)
    end)
  end

  defp increment_action_points(combatant_entity) do
    if Ecspanse.Query.has_component?(combatant_entity, Components.ActionPoints) do
      {:ok, action_points_component} = Components.ActionPoints.fetch(combatant_entity)

      Ecspanse.Command.update_component!(action_points_component,
        current: min(action_points_component.current + 2, action_points_component.max)
      )
    end
  end

  defp set_waiting_for_intentions(%Ecspanse.Entity{} = combatant_entity) do
    {:ok, combatant} = Components.Combatant.fetch(combatant_entity)
    Ecspanse.Command.update_component!(combatant, waiting_for_intentions: true)
  end

  def map_set_put_if(map_set, condition, value) do
    if condition do
      MapSet.put(map_set, value)
    else
      map_set
    end
  end

  defp spawn_available_actions(%Ecspanse.Entity{} = combatant_entity) do
    with {:ok, {grenade_pouch}} <-
           Ecspanse.Query.fetch_components(combatant_entity, {Components.GrenadePouch}),
         {:ok, firearm} <- Ecspanse.Query.fetch_tagged_component(combatant_entity, [:firearm]),
         {:ok, profession} <-
           Ecspanse.Query.fetch_tagged_component(combatant_entity, [:profession]) do
      MapSet.new()
      |> MapSet.put(
        case profession.type do
          :sniper -> {Actions.Dodge, [action_point_cost: 2]}
          _ -> {Actions.Dodge, [action_point_cost: 1]}
        end
      )
      |> MapSet.put(
        case {profession.type, firearm.packed} do
          {:pistolero, _} -> {Actions.Movement.Advance, []}
          {_, true} -> {Actions.Movement.Advance, [action_point_cost: 1]}
          {_, _} -> {Actions.Movement.Advance, [action_point_cost: 3]}
        end
      )
      |> map_set_put_if(profession.type == :pistolero, {Actions.Movement.Rush, []})
      |> map_set_put_if(
        profession.type == :pistolero || firearm.packed == false,
        {Actions.Shooting.Shoot, []}
      )
      |> map_set_put_if(profession.type == :pistolero, {Actions.Shooting.DoubleTap, []})
      |> map_set_put_if(
        profession.type != :pistolero && !firearm.packed,
        {Actions.PackWeapon, []}
      )
      |> map_set_put_if(
        profession.type != :pistolero && firearm.packed,
        {Actions.UnpackWeapon, []}
      )
      |> map_set_put_if(grenade_pouch.explosive > 0, {Actions.TossExplosiveGrenade, []})
      |> map_set_put_if(grenade_pouch.smoke > 0, {Actions.PopSmokeGrenade, []})
    end
    |> Enum.map(fn aa_spec ->
      Entities.AvailableAction.blueprint(combatant_entity, aa_spec)
    end)
    |> Ecspanse.Command.spawn_entities!()
  end
end
