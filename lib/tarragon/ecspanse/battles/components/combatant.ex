defmodule Tarragon.Ecspanse.Battles.Components.Combatant do
  @moduledoc """

  """
  use Ecspanse.Component,
    state: [
      action_points_per_turn: 1,
      waiting_for_intentions: false
    ],
    tags: [:combatant]
end
