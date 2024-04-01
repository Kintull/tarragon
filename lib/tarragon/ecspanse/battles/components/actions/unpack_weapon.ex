defmodule Tarragon.Ecspanse.Battles.Components.Actions.UnpackWeapon do
  @moduledoc """
  Unpacking your weapon increases your move cost but you can shoot
  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Template,
    state: [
      name: "Unpack Weapon",
      icon: "🧩",
      action_point_cost: 2,
      movement_step_modifier: -1
    ],
    tags: [:pack_weapon]
end
