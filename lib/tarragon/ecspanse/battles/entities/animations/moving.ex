defmodule Tarragon.Ecspanse.Battles.Entities.Animations.Moving do
  @moduledoc """
  Create one of these entities for moving another entity.  The parent needs to have a position component.
  """
  alias Tarragon.Ecspanse.Battles.Components

  def new(parent, %{x: start_x, y: start_y}, %{x: end_x, y: end_y}, duration) do
    {Ecspanse.Entity,
     components: [
       {Components.Animations.StartPosition, [x: start_x, y: start_y]},
       {Components.Animations.EndPosition, [x: end_x, y: end_y]},
       {Components.Animations.Moving, [duration: duration]}
     ],
     parents: [parent]}
  end

  def new(parent, %{x: pos_x, y: pos_y}, %{x: dir_x, y: dir_y}, units, duration) do
    {Ecspanse.Entity,
     components: [
       {Components.Animations.StartPosition, [x: pos_x, y: pos_y]},
       {Components.Animations.EndPosition, [x: pos_x + dir_x * units, y: pos_y + dir_y * units]},
       {Components.Animations.Moving, [duration: duration]}
     ],
     parents: [parent]}
  end
end
