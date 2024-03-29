defmodule Tarragon.Ecspanse.Battles.Components.Animations.Moving do
  @moduledoc """
  Duration over which to animate the movement of an entity from one position to another.

  Needs to be on an enity with a start_position and end_position

  ## Fields
  * duration: the travel time in milliseconds
  """
  use Ecspanse.Component,
    state: [duration: 1000],
    tags: [:animation, :moving]
end
