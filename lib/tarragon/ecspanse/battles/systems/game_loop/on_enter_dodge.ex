defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterDodge do
  @moduledoc """
  * Executes scheduled movement actions
  """
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: "Dodge"},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(&Ecspanse.Query.has_component?(&1, Components.Actions.Dodge))

      Enum.each(scheduled_action_entities, &execute_action(&1))

      Ecspanse.Command.despawn_entities!(scheduled_action_entities)
    end
  end

  def run(_, _), do: :ok

  defp execute_action(scheduled_action_entity) do
    with {:ok, combatant} <-
           Lookup.fetch_parent(scheduled_action_entity, Components.Combatant) do
      Ecspanse.Command.add_component!(
        combatant,
        Components.Effects.Dodging
      )
    end
  end
end
