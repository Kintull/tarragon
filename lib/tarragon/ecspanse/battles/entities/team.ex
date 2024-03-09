defmodule Tarragon.Ecspanse.Battles.Entities.Team do
  @moduledoc """
  Factory for creating teams

  """
  alias Tarragon.Ecspanse.Battles.Components

  def blueprint(field_side_factor, name, color, icon \\ "🏴", battle) do
    {Ecspanse.Entity,
     components: [
       {Components.Team, [field_side_factor: field_side_factor]},
       {Components.Brand,
        [
          name: name,
          color: color,
          icon: icon
        ]}
     ],
     parents: [battle]}
  end
end
