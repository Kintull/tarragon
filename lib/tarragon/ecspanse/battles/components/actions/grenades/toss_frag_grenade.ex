defmodule Tarragon.Ecspanse.Battles.Components.Actions.Grenades.TossFragGrenade do
  @moduledoc """

  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Template,
    state: [
      name: "Frag Out",
      action_group: :attack,
      icon: "💥",
      action_point_cost: 1
    ]
end
