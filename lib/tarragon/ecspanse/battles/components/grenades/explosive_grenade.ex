defmodule Tarragon.Ecspanse.Battles.Components.Grenades.ExplosiveGrenade do
  @moduledoc """
  Blows up - damages nearby combatants
  """
  use Tarragon.Ecspanse.Battles.Components.Grenades.Template,
    state: [
      type: :explosive,
      name: "Explosive Grenade",
      icon: "💣",
      range: 2,
      radius: 1,
      damage: 5
    ],
    tags: [:explosive]
end
