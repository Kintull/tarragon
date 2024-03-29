defmodule Tarragon.Ecspanse.Battles.Components.SmokeGrenade do
  @moduledoc """
  An explosive grenade
  """
  use Ecspanse.Component,
    state: [
      count: 0,
      encumbrance: 2,
      icon: "🌫️",
      name: "Smoke Grenade",
      radius: 1,
      range: 1,
      type: :smoke_grenade
    ],
    tags: [:grenade]
end
