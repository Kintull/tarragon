defmodule Tarragon.Ecspanse.Battles.Components.Actions.Shooting.DoubleTap do
  @moduledoc """
  Take 1 high precision shot
  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Shooting.Template,
    state: [
      name: "Two Shots",
      icon: "xx",
      number_of_shots: 2,
      action_point_cost: 3,
      precision_modifier: 1.00,
      damage_modifier: 1.00
    ]
end
