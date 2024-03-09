defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.OnCancelScheduledAction do
  @moduledoc """
  Handles cancelling a scheduled action
  """
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Events

  use Ecspanse.System,
    event_subscriptions: [Events.CancelScheduledAction]

  def run(
        %Events.CancelScheduledAction{scheduled_action_entity_id: scheduled_action_entity_id},
        _frame
      ) do
    with {:ok, scheduled_action_entity} <- Ecspanse.Entity.fetch(scheduled_action_entity_id),
         {:ok, action} <-
           Ecspanse.Query.fetch_tagged_component(scheduled_action_entity, [:action]),
         {:ok, combatant_entity} <-
           Lookup.fetch_parent(scheduled_action_entity, Components.Combatant),
         {:ok, action_points_component} <- Components.ActionPoints.fetch(combatant_entity),
         {:ok, battle_entity} <- Lookup.fetch_ancestor(combatant_entity, Components.Battle),
         {:ok, battle_component} <- Components.Battle.fetch(battle_entity) do
      if battle_component.phase == "Decision Phase" do
        spawn_available_action(scheduled_action_entity, action)

        Ecspanse.Command.update_component!(action_points_component,
          current: action_points_component.current + action.action_point_cost
        )

        Ecspanse.Command.despawn_entity!(scheduled_action_entity)
      end
    end
  end

  defp spawn_available_action(scheduled_action_entity, action) do
    components =
      [
        Components.AvailableAction,
        Components.Utils.to_component_spec(action)
      ]

    parents = Ecspanse.Query.list_parents(scheduled_action_entity)

    Ecspanse.Command.spawn_entity!({Ecspanse.Entity, components: components, parents: parents})
  end
end
