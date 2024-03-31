defmodule Tarragon.Ecspanse.Battles.Entities.Bullet do
  @moduledoc """
  Factory for bullets
  """
  alias Tarragon.Ecspanse.Battles.Components

  def new(parent, %{x: pos_x, y: pos_y}, target_entity_id, damage) do
    {Ecspanse.Entity,
     components: [
       {Components.Bullet, [target_entity_id: target_entity_id, damage: damage]},
       {Components.Position, [x: pos_x, y: pos_y]}
     ],
     parents: [parent]}
  end
end