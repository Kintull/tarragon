defmodule Tarragon.Ecspanse.Battles.Components.Animations.Moving do
  @moduledoc """
  Data to move the combatant

  ## Fields
  * from: the starting x location
  * to: the ending x location
  * duration: the travel time in milliseconds
  """
  use Ecspanse.Component,
    state: [:from, :to, duration: 1000],
    tags: [:animation, :moving]
end
