defmodule Tarragon.Ecspanse.Battles.Components.Battle do
  @moduledoc """
  A battle component for the game.
  """
  use Ecspanse.Component,
    state: [
      game_id: nil,
      name: "Red vs. Blue",
      field_width: 21,
      is_started: false,
      turn: 0,
      max_turns: 30,
      is_completed: false,
      winner_team_id: nil,
      winner_combatant_id: nil
    ],
    tags: [:battle]
end
