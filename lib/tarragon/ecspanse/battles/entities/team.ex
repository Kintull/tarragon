defmodule Tarragon.Ecspanse.Battles.Entities.Team do
  @moduledoc """
  Factory for creating teams

  """
  alias Tarragon.Ecspanse.Battles.Components

  @spec new(String.t(), String.t(), String.t(), Ecspanse.Entity.t()) ::
          Ecspanse.Entity.entity_spec()
  def new(name, color, icon \\ "🏴", battle_entity) do
    {
      Ecspanse.Entity,
      components: [
        Components.Team,
        {Components.Brand,
         [
           name: name,
           color: color,
           icon: icon
         ]}
      ],
      parents: [battle_entity]
    }
  end
end
