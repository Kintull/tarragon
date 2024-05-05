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

  use Ecspanse.System,
    event_subscriptions: [Events.SpawnBattleRequest]

  def run(%Events.SpawnBattleRequest{} = request, _frame) do
    %LobbyGame{} = lobby_game = request.lobby_game
    %GameParameters{} = gp = lobby_game.game_parameters
    %MapParameters{} = mp = gp.map_params

    battle_entity =
      Ecspanse.Command.spawn_entity!(
        Entities.Battle.new(
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

    team_a_entites =
      Enum.zip(team_a_combatants, mp.spawns_team_a)
      |> Enum.map(fn {combatant, spawn_coords} ->
        [
          spawn_comabatant(
            combatant.character_id,
            :sniper,
            red_team,
            gp,
            spawn_coords
          )
        ]
      end)

    team_b_entites =
      Enum.zip(team_b_combatants, mp.spawns_team_b)
      |> Enum.map(fn {combatant, spawn_coords} ->
        [
          spawn_comabatant(
            combatant.character_id,
            :sniper,
            blue_team,
            gp,
            spawn_coords
          )
        ]
      end)

    Ecspanse.Command.spawn_entities!(team_a_entites ++ team_b_entites)
  end

  defp spawn_comabatant(user_id, :pistolero, team, game_parameters, spawn_location) do
    frag_grenade_component = build_frag_grenade_component(game_parameters)

    Entities.Combatant.new_pistolero(
      Faker.Person.first_name(),
      spawn_location,
      [x: -1, y: 0],
      team,
      game_parameters.machine_gunner_params.max_health,
      frag_grenade_component,
      build_weapon(:pistolero, game_parameters),
      user_id
    )
  end

  defp spawn_comabatant(user_id, :sniper, team, game_parameters, spawn_location) do
    frag_grenade_component = build_frag_grenade_component(game_parameters)

    Entities.Combatant.new_sniper(
      Faker.Person.first_name(),
      spawn_location,
      [x: -1, y: 0],
      team,
      game_parameters.sniper_params.max_health,
      frag_grenade_component,
      build_weapon(:sniper, game_parameters),
      user_id
    )
  end

  defp spawn_comabatant(user_id, :machine_gunner, team, game_parameters, spawn_location) do
    frag_grenade_component = build_frag_grenade_component(game_parameters)

    Entities.Combatant.new_gunner(
      Faker.Person.first_name(),
      spawn_location,
      [x: -1, y: 0],
      team,
      game_parameters.machine_gunner_params.max_health,
      frag_grenade_component,
      build_weapon(:machine_gunner, game_parameters),
      user_id
    )
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
end
