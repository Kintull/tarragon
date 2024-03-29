defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterMove do
  @moduledoc """
  * Executes scheduled movement actions
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  use Entities.GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.move
  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(
          &match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:action, :movement]))
        )

      if Enum.any?(scheduled_action_entities) do
        scheduled_action_entities
        |> Enum.map(
          &(Ecspanse.Query.fetch_tagged_component(&1, [:movement])
            |> Withables.val_or_nil())
        )
        |> Enum.map(&spawn_moving_animations/1)

        Ecspanse.Command.despawn_entities!(scheduled_action_entities)
      else
        EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
      end
    end
  end

  def run(_, _), do: :ok

  def spawn_moving_animations(movement_component) do
    scheduled_action_entity = Ecspanse.Query.get_component_entity(movement_component)

    with {:ok, combatant_entity} <-
           Lookup.fetch_parent(scheduled_action_entity, Components.Combatant),
         {:ok, {%Components.Position{} = position, %Components.Direction{} = direction}} <-
           Ecspanse.Query.fetch_components(
             combatant_entity,
             {Components.Position, Components.Direction}
           ) do
      Ecspanse.Command.spawn_entity!(
        Entities.Animations.Moving.new(
          combatant_entity,
          position,
          direction,
          movement_component.steps,
          @movement_durations.combatants
        )
      )
    end
  end
end
