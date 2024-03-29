defmodule Tarragon.Ecspanse.Battles.Components.Actions.Grenades.PopSmokeGrenade do
  @moduledoc """

  """
  use Tarragon.Ecspanse.Battles.Components.Actions.Template,
    state: [
      name: "Pop Smoke",
      action_group: :defense,
      icon: "🌫️",
      action_point_cost: 1
    ]
end
