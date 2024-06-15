defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterFragOut do
  @moduledoc """
  Current does nothing but transition to decision phase
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.frag_out

  require Logger

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    Logger.debug("OnEnterFragOut #{entity_id}")

    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(
          &Ecspanse.Query.has_component?(&1, Components.Actions.Grenades.TossFragGrenade)
        )

      if Enum.any?(scheduled_action_entities) do
        # decrement frag grenade counts
        scheduled_action_entities
        |> Enum.map(fn sae ->
          with {:ok, combatant_entity} <- Lookup.fetch_parent(sae, Components.Combatant),
               {:ok, frag_grenade} = Components.FragGrenade.fetch(combatant_entity) do
            {frag_grenade, [count: frag_grenade.count - 1]}
          end
        end)
        |> Ecspanse.Command.update_components!()

        spawn_frag_grenades(battle_entity, scheduled_action_entities)

        Ecspanse.Command.despawn_entities!(scheduled_action_entities)
      else
        EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
      end
    end
  end

  def run(_, _), do: :ok

  defp spawn_frag_grenades(battle_entity, scheduled_action_entities) do
    scheduled_action_entities
    |> Enum.each(&spawn_grenade(battle_entity, &1))
  end

  defp spawn_grenade(battle_entity, scheduled_action_entity) do
    with {:ok, combatant_entity} <-
           Lookup.fetch_parent(scheduled_action_entity, Components.Combatant),
         {:ok, {position, direction}} <-
           Ecspanse.Query.fetch_components(
             combatant_entity,
             {Components.Position, Components.Direction}
           ) do
      grenade_entity =
        Ecspanse.Command.spawn_entity!(Entities.FragGrenade.new(battle_entity, position))

      Ecspanse.Command.spawn_entity!(
        Entities.Animations.Moving.new(
          grenade_entity,
          position,
          direction,
          2,
          @movement_durations.grenades
        )
      )
    end
  end
end
