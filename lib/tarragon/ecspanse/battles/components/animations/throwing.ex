defmodule Tarragon.Ecspanse.Battles.Components.Animations.Throwing do
  @moduledoc """
  Data to move the combatant
  """
  use Ecspanse.Component,
    state: [:from, :to, duration_in_milliseconds: 1000],
    tags: [:animation, :throwing]
end
