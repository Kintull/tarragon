defmodule Tarragon.Ecspanse.Battles.Entities.AvailableAction do
  @moduledoc """
  Actions available to the component during the decision phase
  """
  alias Tarragon.Ecspanse.Battles.Components

  def new(combatant_entity, action_component_spec) do
    {Ecspanse.Entity,
     components: [
       Components.AvailableAction,
       action_component_spec
     ],
     parents: [combatant_entity]}
  end
end
