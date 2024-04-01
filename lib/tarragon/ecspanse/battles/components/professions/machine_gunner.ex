defmodule Tarragon.Ecspanse.Battles.Components.Professions.MachineGunner do
  @moduledoc """
  Character specializes in mid-range combat with machine guns
  """

  use Tarragon.Ecspanse.Battles.Components.Professions.Template,
    state: [
      name: "Machine Gunner",
      type: :machine_gunner
    ],
    tags: [:machine_gunner]
end
