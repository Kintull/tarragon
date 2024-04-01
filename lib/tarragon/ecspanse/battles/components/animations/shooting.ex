defmodule Tarragon.Ecspanse.Battles.Components.Animations.Shooting do
  @moduledoc """
  Data to move the combatant
  """
  use Ecspanse.Component,
    state: [:from, :to, duration_in_milliseconds: 1000],
    tags: [:animation, :shooting]
end
