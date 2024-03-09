defmodule Tarragon.Ecspanse.Battles.Components.Firearms.MachineGun do
  @moduledoc """
  Pistol component
  """
  use Tarragon.Ecspanse.Battles.Components.Firearms.Template,
    state: [
      type: :machine_gun,
      name: "Machine Gun",
      icon: "🔫🔫",
      range: 3,
      projectiles_per_shot: 10,
      damage_per_projectile: 1,
      miss_chance: 0.30,
      # maybe chance_to_hit_other_body_parts should be a separate component?
      chance_to_hit_other_body_parts: 0.1,
      packable: true
    ],
    tags: [:firearm, :machine_gun]
end
