defmodule Tarragon.Ecspanse.Battles.Components.Grenades.SmokeGrenade do
  @moduledoc """
  Smoke grenades provide obscured effect to combatants at the detonation position
  """
  use Tarragon.Ecspanse.Battles.Components.Grenades.Template,
    state: [
      type: :smoke,
      name: "Smoke Grenade",
      icon: "😶‍🌫️",
      range: 0,
      radius: 0,
      damage: 0
    ],
    tags: [:smoke]
end
