defmodule Tarragon.Ecspanse.Battles.Components.Firearms.Pistol do
  @moduledoc """
  Pistol component
  """
  use Tarragon.Ecspanse.Battles.Components.Firearms.Template,
    state: [
      type: :pistol,
      name: "Pistol",
      icon: "🔫",
      range: 1,
      projectiles_per_shot: 1,
      damage_per_projectile: 6,
      miss_chance: 0.01,
      chance_to_hit_other_body_parts: 0.0,
      packable: false
    ],
    tags: [:pistol]
end
