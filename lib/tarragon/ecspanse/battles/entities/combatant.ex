defmodule Tarragon.Ecspanse.Battles.Entities.Combatant do
  @moduledoc """
  Factories for combatants
  """
  alias Tarragon.Ecspanse.Battles.Components

  # defp side_factor(side) when side == :left, do: -1
  # defp side_factor(_side), do: 1

  def pistolero_blueprint(name, starting_position, team) do
    {Ecspanse.Entity,
     components: [
       Components.ActionPoints,
       {Components.Brand, [name: name, color: "#" <> Faker.Color.rgb_hex()]},
       Components.Combatant,
       Components.Professions.Pistolero,
       Components.Firearms.Pistol,
       {Components.GrenadePouch, [smoke: 1, explosive: 1]},
       Components.Health,
       {Components.Position, [x: starting_position]}
     ],
     parents: [team]}
  end

  def gunner_blueprint(name, starting_position, team) do
    {Ecspanse.Entity,
     components: [
       Components.ActionPoints,
       {Components.Brand, [name: name, color: "#" <> Faker.Color.rgb_hex()]},
       Components.Combatant,
       Components.Professions.MachineGunner,
       Components.Firearms.MachineGun,
       {Components.GrenadePouch, [smoke: 1, explosive: 1]},
       Components.Health,
       {Components.Position, [x: starting_position]}
     ],
     parents: [team]}
  end

  def sniper_blueprint(name, starting_position, team) do
    {Ecspanse.Entity,
     components: [
       Components.ActionPoints,
       {Components.Brand, [name: name, color: "#" <> Faker.Color.rgb_hex()]},
       Components.Combatant,
       Components.Professions.Sniper,
       Components.Firearms.SniperRifle,
       {Components.GrenadePouch, [smoke: 1]},
       Components.Health,
       {Components.Position, [x: starting_position]}
     ],
     parents: [team]}
  end
end
