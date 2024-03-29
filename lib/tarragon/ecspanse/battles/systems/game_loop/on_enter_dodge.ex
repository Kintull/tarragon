defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterDodge do
  @moduledoc """
  * Executes scheduled movement actions
  """
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components
  use Entities.GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.dodge

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(&Ecspanse.Query.has_component?(&1, Components.Actions.Dodge))

      if Enum.any?(scheduled_action_entities) do
        Enum.each(scheduled_action_entities, &add_dodging(&1))

        Ecspanse.Command.despawn_entities!(scheduled_action_entities)
      else
        EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
      end
    end
  end

  def run(_, _), do: :ok

  defp add_dodging(scheduled_action_entity) do
    with {:ok, combatant} <-
           Lookup.fetch_parent(scheduled_action_entity, Components.Combatant) do
      Ecspanse.Command.add_component!(
        combatant,
        Components.Effects.Dodging
      )
    end
  end
end
