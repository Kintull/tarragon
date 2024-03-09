defmodule Tarragon.Ecspanse.Battles.Components.Actions.Movement.Rush do
  @moduledoc """
  Move two cells
  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Movement.Template,
    state: [name: "Rush", icon: "🏃", steps: 2, action_point_cost: 3]
end
