defmodule Tarragon.Ecspanse.Battles.Entities.FragGrenade do
  @moduledoc """
  Factory for grenades
  """
  alias Tarragon.Ecspanse.Battles.Components

  def new(parent, %{x: pos_x, y: pos_y}) do
    {Ecspanse.Entity,
     components: [
       Components.FragGrenade,
       {Components.Position, [x: pos_x, y: pos_y]}
     ],
     parents: [parent]}
  end
end
