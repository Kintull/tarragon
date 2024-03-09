defmodule Tarragon.Ecspanse.Battles.Components.Team do
  @moduledoc """
  One of the sides in the battle.

  A team will have combatants as children

  ## Fields
  * field_side_factor: positive 1 when combatants are on the right and move left or negative -1 for the opposite
  """
  use Ecspanse.Component,
    state: [
      field_side_factor: 0
    ],
    tags: [:team]
end
