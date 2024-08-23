defmodule Tarragon.Ecspanse.Battles.Entities.AttackTargetOption do
  @moduledoc """
  Entity to distinguish attack options
  """
  alias Tarragon.Ecspanse.Battles.Components

  def new(attack_target_option_spec, combatant_entity) do
    {Ecspanse.Entity,
     components: [
       {Components.AttackTargetOption, attack_target_option_spec}
     ],
     parents: [combatant_entity]}
  end
end
