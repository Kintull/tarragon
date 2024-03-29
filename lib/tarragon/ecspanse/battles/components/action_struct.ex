defmodule Tarragon.Ecspanse.Battles.Components.ActionStruct do
  @enforce_keys [:name, :action_group, :icon, :action_point_cost]

  defstruct name: nil, action_group: nil, icon: "a", action_point_cost: 1

  @type t :: %__MODULE__{
          name: String.t(),
          action_group: atom(),
          icon: String.t(),
          action_point_cost: pos_integer()
        }
end
