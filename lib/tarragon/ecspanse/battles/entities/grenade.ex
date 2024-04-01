defmodule Tarragon.Ecspanse.Battles.Entities.Grenade do
  @moduledoc """
  Factory for grenades
  """
  alias Tarragon.Ecspanse.Battles.Components

  def smoke_grenade_blueprint(parent, x) do
    {Ecspanse.Entity,
     components: [
       Components.Grenades.SmokeGrenade,
       {Components.Position, [x: x]}
     ],
     parents: [parent]}
  end

  def explosive_grenade_blueprint(parent, x) do
    {Ecspanse.Entity,
     components: [
       Components.Grenades.ExplosiveGrenade,
       {Components.Position, [x: x]}
     ],
     parents: [parent]}
  end

  def explosive_grenade_blueprint(parent, start_x, end_x) do
    {Ecspanse.Entity,
     components: [
       Components.Grenades.ExplosiveGrenade,
       {Components.Position, [x: start_x]},
       {Components.Animations.Moving, [from: start_x, to: end_x]}
     ],
     parents: [parent]}
  end
end
