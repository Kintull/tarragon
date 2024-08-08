defmodule Tarragon.Ecspanse.Battles.Entities.Animations.MovingHex do
  @moduledoc """
  Create one of these entities for moving another entity.  The parent needs to have a position component.
  """
  alias Tarragon.Ecspanse.Battles.Components

  def new(parent, %{x: start_x, y: start_y, z: start_z}, %{x: end_x, y: end_y, z: end_z}, duration) do
    {Ecspanse.Entity,
     components: [
       {Components.Animations.StartPosition, [x: start_x, y: start_y, z: start_z]},
       {Components.Animations.EndPosition, [x: end_x, y: end_y, z: end_z]},
       {Components.Animations.Moving, [duration: duration]}
     ],
     parents: [parent]}
  end

  def new(parent, %{x: pos_x, y: pos_y, z: pos_z}, %{x: dir_x, y: dir_y, z: dir_z}, units, duration) do
    {Ecspanse.Entity,
     components: [
       {Components.Animations.StartPosition, [x: pos_x, y: pos_y, z: pos_z]},
       {Components.Animations.EndPosition, [x: pos_x + dir_x * units, y: pos_y + dir_y * units, z: pos_z + dir_z * units]},
       {
         Components.Animations.Moving, [duration: duration]}
     ],
     parents: [parent]}
  end
end
