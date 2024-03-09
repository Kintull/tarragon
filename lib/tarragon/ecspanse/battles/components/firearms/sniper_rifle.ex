defmodule Tarragon.Ecspanse.Battles.Components.Firearms.SniperRifle do
  @moduledoc """
  Pistol component
  """
  use Tarragon.Ecspanse.Battles.Components.Firearms.Template,
    state: [
      type: :sniper_rifle,
      name: "Sniper Rifle",
      icon: "🔫🔫🔫",
      range: 7,
      projectiles_per_shot: 1,
      damage_per_projectile: 18,
      miss_chance: 0.01,
      packable: true
    ],
    tags: [:sniper_rifle]
end
