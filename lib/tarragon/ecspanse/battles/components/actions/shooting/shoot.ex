defmodule Tarragon.Ecspanse.Battles.Components.Actions.Shooting.Shoot do
  @moduledoc """
  Take 1 shot
  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Shooting.Template,
    state: [
      name: "Shoot",
      icon: "x",
      number_of_shots: 1,
      action_point_cost: 2,
      precision_modifier: 1.00,
      damage_modifier: 1.00
    ]
end
