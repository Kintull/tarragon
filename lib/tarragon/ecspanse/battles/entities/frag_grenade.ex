defmodule Tarragon.Ecspanse.Battles.Entities.FragGrenade do
  @moduledoc """
  Factory for grenades
  """
  alias Tarragon.Ecspanse.Battles.Components.FragGrenade
  alias Tarragon.Ecspanse.Battles.Components.Position

  def new(parent, %{x: pos_x, y: pos_y}) do
    {Ecspanse.Entity,
     components: [
       FragGrenade,
       {Position, [x: pos_x, y: pos_y]}
     ],
     parents: [parent]}
  end
end
