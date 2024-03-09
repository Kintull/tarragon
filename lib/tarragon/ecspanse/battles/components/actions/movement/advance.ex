defmodule Tarragon.Ecspanse.Battles.Components.Actions.Movement.Advance do
  @moduledoc """
  Move one cell
  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Movement.Template,
    state: [name: "Advance", icon: "🚶", steps: 1, action_point_cost: 2]
end
