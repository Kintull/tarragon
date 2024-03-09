defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.OnScheduleAvailableAction do
  @moduledoc """
  Handles converting an available action to a scheduled action upon event
  """
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Events

  use Ecspanse.System,
    event_subscriptions: [Events.ScheduleAvailableAction]

  def run(
        %Events.ScheduleAvailableAction{available_action_entity_id: available_action_entity_id},
        _frame
      ) do
    with {:ok, available_action_entity} <- Ecspanse.Entity.fetch(available_action_entity_id),
         {:ok, action} <-
           Ecspanse.Query.fetch_tagged_component(available_action_entity, [:action]),
         {:ok, combatant_entity} <-
           Lookup.fetch_parent(available_action_entity, Components.Combatant),
         {:ok, action_points_component} <- Components.ActionPoints.fetch(combatant_entity) do
      if action.action_point_cost <= action_points_component.current do
        spawn_scheduled_action(available_action_entity, action)

        Ecspanse.Command.update_component!(action_points_component,
          current: action_points_component.current - action.action_point_cost
        )

        Ecspanse.Command.despawn_entity!(available_action_entity)
      end
    end
  end

  defp spawn_scheduled_action(available_action_entity, action) do
    components =
      [
        Components.ScheduledAction,
        Components.Utils.to_component_spec(action)
      ]

    parents = Ecspanse.Query.list_parents(available_action_entity)

    Ecspanse.Command.spawn_entity!({Ecspanse.Entity, components: components, parents: parents})
  end
end
