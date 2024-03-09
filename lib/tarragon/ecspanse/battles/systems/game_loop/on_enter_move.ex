defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterMove do
  @moduledoc """
  * Executes scheduled movement actions
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: "Move"},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(&match?({:ok, _}, Ecspanse.Query.fetch_tagged_component(&1, [:movement])))

      scheduled_action_entities
      |> Enum.map(
        &(Ecspanse.Query.fetch_tagged_component(&1, [:movement])
          |> Withables.val_or_nil())
      )
      |> Enum.map(&create_animation_spec/1)
      |> Ecspanse.Command.add_components!()

      Ecspanse.Command.despawn_entities!(scheduled_action_entities)
    end
  end

  def run(_, _), do: :ok

  def create_animation_spec(movement_component) do
    scheduled_action_entity = Ecspanse.Query.get_component_entity(movement_component)

    with {:ok, combatant_entity} <-
           Lookup.fetch_parent(scheduled_action_entity, Components.Combatant),
         {:ok, position} <- Ecspanse.Query.fetch_component(combatant_entity, Components.Position),
         {:ok, team_entity} <- Lookup.fetch_parent(combatant_entity, Components.Team),
         {:ok, team_component} <- Ecspanse.Query.fetch_component(team_entity, Components.Team) do
      {combatant_entity,
       [
         {Components.Animations.Moving,
          [
            from: position.x,
            to: position.x + movement_component.steps * team_component.field_side_factor
          ]}
       ]}
    end
  end
end
