defmodule Tarragon.Ecspanse.Battles.Components.FragGrenade do
  @moduledoc """
  An explosive grenade
  """
  use Ecspanse.Component,
    state: [
      count: 0,
      damage: 5,
      encumbrance: 2,
      icon: "💣",
      name: "Frag Grenade",
      range: 2,
      radius: 1,
      type: :frag_grenade
    ],
    tags: [:grenade]

  def new(count, damage, encumbrance, radius, range) do
    {__MODULE__,
     count: count, damage: damage, encumbrance: encumbrance, radius: radius, range: range}
  end
end
