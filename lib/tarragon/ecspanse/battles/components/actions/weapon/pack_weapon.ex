defmodule Tarragon.Ecspanse.Battles.Components.Actions.Weapon.PackWeapon do
  @moduledoc """
  Packing your weapon decreases your move cost but you cannot shoot
  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Template,
    state: [
      name: "Pack Weapon",
      action_group: :weapon,
      icon: "💼",
      action_point_cost: 2,
      movement_step_modifier: 1
    ],
    tags: [:pack_weapon]
end
