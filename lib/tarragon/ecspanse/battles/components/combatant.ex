defmodule Tarragon.Ecspanse.Battles.Components.Combatant do
  @moduledoc """

  """
  use Ecspanse.Component,
    state: [
      action_points_per_turn: 2,
      encumbrance: 0,
      user_id: nil,
      waiting_for_intentions: false
    ],
    tags: [:combatant]
end
