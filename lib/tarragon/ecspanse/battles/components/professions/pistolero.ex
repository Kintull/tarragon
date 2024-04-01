defmodule Tarragon.Ecspanse.Battles.Components.Professions.Pistolero do
  @moduledoc """
  Character specializes in close combat with pistols
  """

  use Tarragon.Ecspanse.Battles.Components.Professions.Template,
    state: [
      name: "Pistolero",
      type: :pistolero
    ],
    tags: [:pistolero]
end
