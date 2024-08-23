defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterMove do
  @moduledoc """
  * Executes scheduled movement actions
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  require Logger

  @to_state @state_names.move
  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    Logger.debug("OnEnterMove #{entity_id}")

    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      action_entities =
        Lookup.list_descendants(battle_entity, Components.ActionState)
        |> Enum.filter(
          &match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:action, :movement]))
        )
        |> Enum.filter(
             &match?({:ok, %{is_scheduled: true}}, Components.ActionState.fetch(&1))
           )

      if Enum.any?(action_entities) do
        action_entities
        |> Enum.map(
          &(Ecspanse.Query.fetch_tagged_component(&1, [:movement])
            |> Withables.val_or_nil())
        )
        |> Enum.each(&spawn_moving_animations/1)

        action_entities
        |> Enum.map(
          fn action_entity ->
            {:ok, action_state} = Components.ActionState.fetch(action_entity)
            Ecspanse.Command.update_component!(action_state,
              is_scheduled: false
            )
          end)
      end

      EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
    end
  end

  def run(_, _), do: :ok

  def spawn_moving_animations(movement_component) do
    scheduled_action_entity = Ecspanse.Query.get_component_entity(movement_component)

    with {:ok, combatant_entity} <-
           Lookup.fetch_parent(scheduled_action_entity, Components.Combatant),
         {:ok, {%Components.Position{} = position, %Components.MoveActionDirection{} = direction}} <-
           Ecspanse.Query.fetch_components(
             combatant_entity,
             {Components.Position, Components.MoveActionDirection}
           ) do
      Ecspanse.Command.spawn_entity!(
        Entities.Animations.MovingHex.new(
          combatant_entity,
          position,
          direction,
          @movement_durations.combatants
        )
      )
    end
  end
end
