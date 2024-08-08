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
        %Events.CancelScheduledAction{action_entity_id: action_entity_id},
        _frame
      ) do
    with {:ok, action_entity} <- Ecspanse.Entity.fetch(action_entity_id),
         {:ok, action} <-
           Ecspanse.Query.fetch_tagged_component(action_entity, [:action]),
         {:ok, combatant_entity} <-
           Lookup.fetch_parent(action_entity, Components.Combatant),
         {:ok, action_points_component} <- Components.ActionPoints.fetch(combatant_entity),
         {:ok, battle_entity} <- Lookup.fetch_ancestor(combatant_entity, Components.Battle),
         {:ok, battle_state} <- EcspanseStateMachine.current_state(battle_entity.id),
         {:ok, action_state} <- Components.ActionState.fetch(action_entity) do
      if battle_state == "Decisions Phase" do
        Ecspanse.Command.update_component!(action_state,
          is_scheduled: false
        )

        Ecspanse.Command.update_component!(action_points_component,
          current: action_points_component.current + action.action_point_cost
        )

        update_available_actions(combatant_entity)
#        Ecspanse.Command.despawn_entity!(action_entity)
      end
    end
  end

#  defp spawn_available_action(action_entity, action) do
#    components =
#      [
#        Components.ActionState,
#        Components.Utils.to_component_spec(action)
#      ]
#
#    parents = Ecspanse.Query.list_parents(action_entity)
#
#    Ecspanse.Command.spawn_entity!({Ecspanse.Entity, components: components, parents: parents})
#  end

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
          is_available: action.action_point_cost <= action_points.current
        )
      end)
    end
  end

end
