defmodule Tarragon.Ecspanse.Battles.Entities.Combatant do
  @moduledoc """
  Factories for combatants
  """
  alias Tarragon.Ecspanse.Battles.Components

  def new_pistolero(
        name,
        position,
        direction,
        team,
        max_health,
        frag_grenade,
        main_weapon,
        user_id
      ) do
    components = [
      Components.ActionPoints,
      {Components.Brand, [name: name, color: "#" <> Faker.Color.rgb_hex()]},
      {Components.Combatant, [user_id: user_id]},
      {Components.Direction, direction},
      Components.MoveActionDirection,
      Components.AttackActionTarget,
      frag_grenade,
      {Components.Health, [current: max_health, max: max_health]},
      main_weapon,
      {Components.Position, position},
      Components.Profession.new_pistolero(),
      Components.SmokeGrenade
    ]

    components =
      components
      |> prepend_if(user_id == nil, Components.BotBrain)

    {Ecspanse.Entity, components: components, parents: [team]}
  end

  defp prepend_if(list, condition, component) do
    case condition do
      true -> [component | list]
      false -> list
    end
  end

  def new_gunner(name, position, direction, team, max_health, frag_grenade, main_weapon, user_id) do
    components = [
      Components.ActionPoints,
      {Components.Brand, [name: name, color: "#" <> Faker.Color.rgb_hex()]},
      {Components.Combatant, [user_id: user_id]},
      {Components.Direction, direction},
      Components.MoveActionDirection,
      Components.AttackActionTarget,
      frag_grenade,
      {Components.Health, [current: max_health, max: max_health]},
      main_weapon,
      {Components.Position, position},
      Components.Profession.new_machine_gunner(),
      Components.SmokeGrenade
    ]

    components =
      components
      |> prepend_if(user_id == nil, Components.BotBrain)

    {Ecspanse.Entity, components: components, parents: [team]}
  end

  def new_sniper(name, position, direction, team, max_health, frag_grenade, main_weapon, user_id) do
    components = [
      Components.ActionPoints,
      {Components.Brand, [name: name, color: "#" <> Faker.Color.rgb_hex()]},
      {Components.Combatant, [user_id: user_id]},
      {Components.Direction, direction},
      Components.MoveActionDirection,
      Components.AttackActionTarget,
      frag_grenade,
      {Components.Health, [current: max_health, max: max_health]},
      main_weapon,
      {Components.Position, position},
      Components.Profession.new_sniper(),
      Components.SmokeGrenade
    ]

    components =
      components
      |> prepend_if(user_id == nil, Components.BotBrain)

    {Ecspanse.Entity, components: components, parents: [team]}
  end
end
