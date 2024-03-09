defmodule Tarragon.Ecspanse.Battles.Components.Firearms.Template do
  @moduledoc """
  Shoots one or more projectiles
  """
  use Ecspanse.Template.Component,
    state: [
      :type,
      :name,
      icon: "w",
      range: 1,
      projectiles_per_shot: 1,
      damage_per_projectile: 1,
      miss_chance: 0.1,
      chance_to_hit_other_body_parts: 0.0,
      packable: false,
      packed: false
    ],
    tags: [:firearm]
end
