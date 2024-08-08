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
         {:ok, action_points_component} <- Components.ActionPoints.fetch(combatant_entity),
         {:ok, action_state} <- Components.ActionState.fetch(available_action_entity)
        do
      if action.action_point_cost <= action_points_component.current do
        Ecspanse.Command.update_component!(action_state,
          is_scheduled: true
        )

        Ecspanse.Command.update_component!(action_points_component,
          current: action_points_component.current - action.action_point_cost
        )

        update_available_actions(combatant_entity)
      end
    end
  end

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
