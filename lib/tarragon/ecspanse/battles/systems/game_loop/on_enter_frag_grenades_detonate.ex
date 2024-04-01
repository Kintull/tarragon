defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterFragGrenadesDetonate do
  @moduledoc """
  * Executes scheduled movement actions
  """
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components
  use Entities.GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.frag_grenades_detonate

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      grenade_entities =
        Lookup.list_children(battle_entity, Components.FragGrenade)

      if Enum.any?(grenade_entities) do
        combatant_entities =
          Lookup.list_descendants(battle_entity, Components.Combatant)

        combatant_entities_by_x =
          combatant_entities
          |> Enum.group_by(&get_combatant_x(&1), & &1)

        current_health_by_entity =
          combatant_entities
          |> Enum.reduce(%{}, fn ce, acc ->
            with {:ok, health} <- Ecspanse.Query.fetch_component(ce, Components.Health) do
              Map.put(acc, ce, health.current)
            end
          end)

        updated_health_by_entity =
          grenade_entities
          |> Enum.reduce(
            current_health_by_entity,
            fn g, acc -> detonate(g, combatant_entities_by_x, acc) end
          )

        updated_health_by_entity
        |> Enum.map(fn {entity, new_health} ->
          with {:ok, health} <- Ecspanse.Query.fetch_component(entity, Components.Health) do
            {health, current: new_health}
          end
        end)
        |> Ecspanse.Command.update_components!()

        grenade_entities
        |> Ecspanse.Command.despawn_entities!()
      else
        EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
      end
    end
  end

  def run(_, _), do: :ok

  defp detonate(grenade_entity, combatant_entities_by_x, current_health_by_entity) do
    with {:ok, {grenade_position, grenade}} <-
           Ecspanse.Query.fetch_components(
             grenade_entity,
             {Components.Position, Components.FragGrenade}
           ) do
      Range.new(grenade_position.x - grenade.radius, grenade_position.x + grenade.radius)
      |> Enum.map(&Map.get(combatant_entities_by_x, &1, []))
      |> List.flatten()
      |> Enum.reduce(current_health_by_entity, fn ce, acc ->
        current = Map.get(acc, ce)
        Map.put(acc, ce, current - grenade.damage)
      end)
    end
  end

  defp get_combatant_x(combatant_entity) do
    case Ecspanse.Query.fetch_component(combatant_entity, Components.Position) do
      {:ok, position} -> position.x
      err -> err
    end
  end
end
