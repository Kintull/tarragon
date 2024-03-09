defmodule Tarragon.Ecspanse.Battles.Entities.ScheduledAction do
  alias Tarragon.Ecspanse.Battles.Components

  def blueprint(combatant_entity, action_component_spec) do
    {Ecspanse.Entity,
     components: [
       Components.ScheduledAction,
       action_component_spec
     ],
     parents: [combatant_entity]}
  end
end
