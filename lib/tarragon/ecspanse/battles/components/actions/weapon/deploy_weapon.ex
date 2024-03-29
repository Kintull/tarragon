defmodule Tarragon.Ecspanse.Battles.Components.Actions.Weapon.DeployWeapon do
  @moduledoc """
  Deploying your weapon increases your move cost but you can shoot
  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Template,
    state: [
      name: "Deploy Weapon",
      action_group: :weapon,
      icon: "🧩",
      action_point_cost: 2
    ],
    tags: [:deploy_weapon]
end
