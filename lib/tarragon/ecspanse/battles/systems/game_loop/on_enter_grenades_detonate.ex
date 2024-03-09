defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterGrenadesDetonate do
  @moduledoc """
  * Executes scheduled movement actions
  """
  alias TarragonWeb.PageLive.Ecspanse.EcspanseComponents
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @state "Grenades Detonate"

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @state},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      grenade_entities =
        Lookup.fetch_child(battle_entity, Components.Grenades.ExplosiveGrenade)
        |> IO.inspect(label: "grenades")

      if Enum.any?(grenade_entities) do
        combatant_entities =
          Lookup.list_descendants(battle_entity, Components.Combatant)

        combatant_entities_by_x =
          combatant_entities
          |> Enum.group_by(&get_combatant_x(&1), & &1)
          |> IO.inspect(label: "combatant_entities_by_x")

        current_health_by_entity =
          combatant_entities
          |> Enum.reduce(%{}, fn ce, acc ->
            with {:ok, health} <- Ecspanse.Query.fetch_component(ce, Components.Health) do
              Map.put(acc, ce, health.current)
            end
          end)
          |> IO.inspect(label: "current_health_by_entity")

        updated_health_by_entity =
          grenade_entities
          |> Enum.each(&detonate(&1, combatant_entities_by_x, current_health_by_entity))
          |> IO.inspect(label: "updated_health_by_entity")

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
        with {:ok, [next_state, _]} <-
               EcspanseStateMachine.fetch_state_exits_to(entity_id, @state) do
          EcspanseStateMachine.change_state(entity_id, @state, next_state)
        end
      end
    end
  end

  def run(_, _), do: :ok

  defp detonate(grenade_entity, combatant_entities_by_x, current_health_by_entity) do
    with {:ok, {grenade_position, grenade}} <-
           Ecspanse.Query.fetch_components(
             grenade_entity,
             {Components.Position, Components.Grenades.ExplosiveGrenade}
           ) do
      Range.new(grenade_position.x - grenade.radius, grenade_position.x + grenade.radius)
      |> Enum.map(&Map.get(combatant_entities_by_x, &1, []))
      |> Enum.reduce(current_health_by_entity, fn ce, acc ->
        Map.get_and_update(acc, ce, fn current ->
          {current, current - grenade.damage}
        end)
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
