defmodule Tarragon.Ecspanse.Battles.Entities.BattleEntity do
  @moduledoc """
  Factory for creating a battle
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup
  require Logger

  use GameLoopConstants

  def new(game_id, name, max_turns) do
    {Ecspanse.Entity,
     components: [
       {Components.Battle, [game_id: game_id, max_turns: max_turns, name: name]},
       EcspanseStateMachine.new(
         "Battle Start",
         [
           [
             name: @state_names.battle_start,
             exits: [@state_names.decisions_phase],
             timeout: 2_000
           ],
           [
             name: @state_names.decisions_phase,
             exits: [@state_names.action_phase_start],
             timeout: 10_000
           ],
           [
             name: @state_names.action_phase_start,
             exits: [@state_names.pop_smoke],
             timeout: 1_000
           ],
           [name: @state_names.pop_smoke, exits: [@state_names.frag_out], timeout: 1],
           [
             name: @state_names.frag_out,
             exits: [@state_names.dodge],
             timeout: 1
           ],
           [name: @state_names.dodge, exits: [@state_names.deploy_weapons], timeout: 1_000],
           [name: @state_names.deploy_weapons, exits: [@state_names.fire_weapon], timeout: 1],
           [
             name: @state_names.fire_weapon,
             exits: [@state_names.bullets_impact],
             timeout: @movement_durations.bullets
           ],
           [
             name: @state_names.bullets_impact,
             exits: [@state_names.frag_grenades_detonate],
             timeout: 1_000
           ],
           [
             name: @state_names.frag_grenades_detonate,
             exits: [@state_names.pack_weapons],
             timeout: 1_000
           ],
           [name: @state_names.pack_weapons, exits: [@state_names.move], timeout: 1],
           [
             name: @state_names.move,
             exits: [@state_names.action_phase_end],
             timeout: @movement_durations.combatants
           ],
           [
             name: @state_names.action_phase_end,
             exits: [@state_names.decisions_phase, @state_names.battle_end]
           ],
           [name: @state_names.battle_end]
         ],
         auto_start: false
       )
     ]}
  end

  @spec list_living_combatants(Ecspanse.Entity.t()) :: list(Ecspanse.Entity.t())
  @doc """
  Returns a list of entities descendent from the battle entity that have current health > 0.
  """
  def list_living_combatants(%Ecspanse.Entity{} = entity) do
    Lookup.list_descendants(entity, Components.Combatant)
    |> Enum.filter(fn descendant ->
      {:ok, health_component} = Components.Health.fetch(descendant)
      health_component.current > 0
    end)
  end

  def enemies_by_distance_from_me(battle_entity, combatant_entity) do
    with {:ok, position} <- Components.Position.fetch(combatant_entity) do
      get_other_team_combatants(battle_entity, combatant_entity)
      |> Enum.group_by(fn ee ->
        with {:ok, enemy_position} <- Components.Position.fetch(ee) do
            dx = abs(position.x - enemy_position.x)
            dy = abs(position.y - enemy_position.y)
            dz = abs(position.z - enemy_position.z)
            div((dx + dy + dz), 2)
         end
      end)
    end
  end

#  def am_i_in_range_of_enemy?(battle_entity, combatant_entity) do
#    with {:ok, position} <- Components.Position.fetch(combatant_entity) do
#      get_other_team_combatants(battle_entity, combatant_entity)
#      |> Enum.any?(fn ee ->
#        with {:ok, {enemy_position, their_weapon}} <-
#               Ecspanse.Query.fetch_components(ee, {Components.Position, Components.MainWeapon}) do
#          abs(position.x - enemy_position.x) <= their_weapon.range
#        end
#      end)
#    end
#  end

  def get_other_team_combatants(battle_entity, combatant_entity) do
    living_combatants = list_living_combatants(battle_entity)

    {:ok, my_team} = Lookup.fetch_parent(combatant_entity, Components.Team)

    Lookup.list_children(battle_entity, Components.Team)
    |> Enum.find(&(&1.id != my_team.id))
    |> Lookup.list_children(Components.Combatant)
    |> Enum.filter(&(&1 in living_combatants))
  end
end
