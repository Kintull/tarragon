defmodule Tarragon.Ecspanse.Battles.Components.Animations.Dodging do
  @moduledoc """
  Data to move the combatant
  """
  @deprecated "use dodging effect"
  use Ecspanse.Component,
    state: [duration_in_milliseconds: 1000],
    tags: [:animation, :dodging]
end
