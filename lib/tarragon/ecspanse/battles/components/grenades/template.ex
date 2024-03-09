defmodule Tarragon.Ecspanse.Battles.Components.Grenades.Template do
  @moduledoc """
  Shoots one or more projectiles
  """
  use Ecspanse.Template.Component,
    state: [
      :type,
      :name,
      icon: "w",
      range: 0,
      radius: 1,
      damage: 0
    ],
    tags: [:grenade]
end
