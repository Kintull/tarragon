defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.NewBattleMonitor do
  @moduledoc """
  Looks for battles that haven't been started and starts them once there are enough combatants
  """
  alias Tarragon.Ecspanse.Battles.Components.Battle

  use Ecspanse.System

  def run(_frame) do
    Ecspanse.Query.select({Ecspanse.Entity, Battle})
    |> Ecspanse.Query.stream()
    |> limit_to_battles_not_started()
    # |> limit_to_battles_with_enough_combatants()
    |> start_battles()
  end

  defp start_battles(entity_battle_tuples) do
    entity_battle_tuples
    |> Enum.each(fn {entity, battle} ->
      EcspanseStateMachine.start(entity.id)
      Ecspanse.Command.update_component!(battle, is_started: true)
    end)
  end

#  defp limit_to_battles_with_enough_combatants(entity_battle_tuples) do
#    entity_battle_tuples
#    |> Enum.filter(fn {entity, _battle} ->
#      Entities.BattleEntity.list_living_combatants(entity) >= 6
#    end)
#  end

  defp limit_to_battles_not_started(entity_battle_tuples) do
    entity_battle_tuples
    |> Enum.filter(fn {_entity, battle} ->
      battle.is_started == false
    end)
  end
end
