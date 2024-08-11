defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.BattleSpawnerV2 do
  @moduledoc """
  Spawns Battles
  """
  alias Tarragon.Ecspanse.Lobby.LobbyGame
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.GameParameters
  alias Tarragon.Ecspanse.MapParameters
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Events
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.Components.Actions
  alias Tarragon.Battles

  use Ecspanse.System,
    event_subscriptions: [Events.SpawnBattleRequest]

  def run(%Events.SpawnBattleRequest{} = request, _frame) do
    %LobbyGame{} = lobby_game = request.lobby_game
    %GameParameters{} = gp = lobby_game.game_parameters
    %MapParameters{} = mp = gp.map_params

    battle_entity =
      Ecspanse.Command.spawn_entity!(
        Entities.BattleEntity.new(
          lobby_game.id,
          "#{gp.red_team_params.name} vs. #{gp.blue_team_params.name}",
          gp.turns
        )
      )

    IO.puts(
      EcspanseStateMachine.format_as_mermaid_diagram(battle_entity.id)
      |> Withables.val_or_nil()
    )

    [red_team, blue_team] =
      Ecspanse.Command.spawn_entities!([
        Entities.Team.new(gp.red_team_params.name, gp.red_team_params.color, "🚩", battle_entity),
        Entities.Team.new(gp.blue_team_params.name, gp.blue_team_params.color, "🏴", battle_entity)
      ])

    team_a_combatants = Enum.filter(lobby_game.player_combatants, &(&1.team == :team_a))
    team_b_combatants = Enum.filter(lobby_game.player_combatants, &(&1.team == :team_b))

    Enum.zip(team_a_combatants, mp.spawns_team_a)
    |> Enum.map(fn {combatant, spawn_coords} ->
      spawn_combatant(
        combatant.character_id,
        :sniper,
        red_team,
        gp,
        Map.to_list(spawn_coords)
      )
      combatant.character_id
    end)

    Enum.zip(team_b_combatants, mp.spawns_team_b)
    |> Enum.map(fn {combatant, spawn_coords} ->
      spawn_combatant(
        combatant.character_id,
        :sniper,
        blue_team,
        gp,
        Map.to_list(spawn_coords)
      )
      combatant.character_id
    end)

  end

  defp spawn_combatant(user_id, :pistolero, team, game_parameters, spawn_location) do
    frag_grenade_component = build_frag_grenade_component(game_parameters)
    bonuses = Battles.impl().build_character_bonuses(user_id)
    Entities.Combatant.new_pistolero(
      Faker.Person.first_name(),
      spawn_location,
      [x: 0, y: 0, z: 0],
      team,
      bonuses.max_health,
      frag_grenade_component,
      build_weapon(:pistolero, game_parameters),
      user_id
    )
    |> Ecspanse.Command.spawn_entity!()
    |> spawn_available_actions()
  end

  defp spawn_combatant(user_id, :sniper, team, game_parameters, spawn_location) do
    frag_grenade_component = build_frag_grenade_component(game_parameters)
    bonuses = Battles.impl().build_character_bonuses(user_id)
    Entities.Combatant.new_sniper(
      Faker.Person.first_name(),
      spawn_location,
      [x: 0, y: 0, z: 0],
      team,
      bonuses.max_health,
      frag_grenade_component,
      build_weapon(:sniper, game_parameters),
      user_id
    )
    |> Ecspanse.Command.spawn_entity!()
    |> spawn_available_actions()
  end

  defp spawn_combatant(user_id, :machine_gunner, team, game_parameters, spawn_location) do
    frag_grenade_component = build_frag_grenade_component(game_parameters)
    bonuses = Battles.impl().build_character_bonuses(user_id)
    Entities.Combatant.new_gunner(
      Faker.Person.first_name(),
      spawn_location,
      [x: 0, y: 0, z: 0],
      team,
      bonuses.max_health,
      frag_grenade_component,
      build_weapon(:machine_gunner, game_parameters),
      user_id
    )
    |> Ecspanse.Command.spawn_entity!()
    |> spawn_available_actions()
  end

  defp build_weapon(:pistolero, game_parameters) do
    Components.MainWeapon.pistol(
      game_parameters.pistolero_params.main_weapon_params.damage_per_projectile,
      game_parameters.pistolero_params.main_weapon_params.projectiles_per_shot,
      game_parameters.pistolero_params.main_weapon_params.range
    )
  end

  defp build_weapon(:machine_gunner, game_parameters) do
    Components.MainWeapon.machine_gun(
      game_parameters.machine_gunner_params.main_weapon_params.damage_per_projectile,
      game_parameters.machine_gunner_params.main_weapon_params.projectiles_per_shot,
      game_parameters.machine_gunner_params.main_weapon_params.range
    )
  end

  defp build_weapon(:sniper, game_parameters) do
    Components.MainWeapon.sniper_rifle(
      game_parameters.sniper_params.main_weapon_params.damage_per_projectile,
      game_parameters.sniper_params.main_weapon_params.projectiles_per_shot,
      game_parameters.sniper_params.main_weapon_params.range
    )
  end

  defp build_frag_grenade_component(game_parameters) do
    {Components.FragGrenade,
     Map.take(game_parameters.frag_grenade_params, [:damage, :encumbrance, :radius, :range])
     |> Map.to_list()
     |> List.insert_at(0, {:count, 1})}
  end

  defp spawn_available_actions(%Ecspanse.Entity{} = combatant_entity) do
    with {:ok, {main_weapon, profession}} <-
           Ecspanse.Query.fetch_components(
             combatant_entity,
             {Components.MainWeapon, Components.Profession}
           ) do

      attack =
        case profession.type do
          :sniper -> {Actions.Shooting.Shoot, [action_point_cost: 2]}
          :pistolero -> {Actions.Shooting.DoubleTap, [action_point_cost: 3]}
          _ -> {Actions.Shooting.Shoot, [action_point_cost: 1]}
        end

      dodge =
        case profession.type do
          :sniper -> {Actions.Dodge, [action_point_cost: 2]}
          _ -> {Actions.Dodge, [action_point_cost: 1]}
        end

      advance =
        case {profession.type, main_weapon.deployed} do
          {:pistolero, _} -> {Actions.Movement.Advance, []}
          {_, false} -> {Actions.Movement.Advance, [action_point_cost: 1]}
          {_, _} -> {Actions.Movement.Advance, [action_point_cost: 3]}
        end

      [dodge, advance, attack]
      |> Enum.map(fn aa_spec ->
        Entities.AvailableAction.new(combatant_entity, aa_spec)
      end)
      |> Ecspanse.Command.spawn_entities!()
    end
  end
end
