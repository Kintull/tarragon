defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.OnSelectMoveTile do
  alias Tarragon.Ecspanse.Battles.Events
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.System,
      event_subscriptions: [Events.SelectMoveTile]

  def run(
        %Events.SelectMoveTile{combatant_entity_id: combatant_entity_id, x: x, y: y, z: z},
        _frame
      ) do
    {:ok, combatant_entity} = Ecspanse.Entity.fetch(combatant_entity_id)
    {:ok, move_direction_component} =
      Ecspanse.Query.fetch_component(
        combatant_entity,
        Components.MoveActionDirection
      )

    Ecspanse.Command.update_component!(move_direction_component, x: x, y: y, z: z)
  end

end
