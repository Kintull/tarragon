defmodule Tarragon.Ecspanse.Battles.Components.Bullet do
  @moduledoc """
  A bullet
  """
  use Ecspanse.Component,
    state: [
      :target_entity_id,
      type: :bullet,
      name: "Bullet",
      icon: "⁍",
      damage: 1
    ],
    tags: [:grenade]

  def new(target_entity_id, damage) do
    {__MODULE__, target_entity_id: target_entity_id, damage: damage}
  end
end
