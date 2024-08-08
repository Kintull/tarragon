defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.OnLockIntentions do
  @moduledoc """
  Updates the combatant and possibly battle phase when a combatant signals they
  have scheduled their choices in the decision phase
  """
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Events
  alias Tarragon.Ecspanse.Battles.Entities

  use Ecspanse.System,
    event_subscriptions: [Events.LockIntentions]

  def run(
        %Events.LockIntentions{combatant_entity_id: combatant_entity_id},
        _frame
      ) do
    with {:ok, combatant_entity} <- Ecspanse.Entity.fetch(combatant_entity_id),
         {:ok, battle_entity} <- Lookup.fetch_ancestor(combatant_entity, Components.Battle) do
      clear_waiting_for_intentions(combatant_entity)

      waiting_on_any_living_combatant =
        Entities.BattleEntity.list_living_combatants(battle_entity)
        |> Enum.map(fn combatant_entity ->
          {:ok, combatant_component} = Components.Combatant.fetch(combatant_entity)
          combatant_component
        end)
        |> Enum.any?(& &1.waiting_for_intentions)

      unless waiting_on_any_living_combatant do
        EcspanseStateMachine.transition_to_default_exit(
          battle_entity.id,
          "Decisions Phase",
          "Intentions Locked"
        )
      end
    end
  end

  defp clear_waiting_for_intentions(%Ecspanse.Entity{} = combatant_entity) do
    {:ok, combatant} = Components.Combatant.fetch(combatant_entity)
    Ecspanse.Command.update_component!(combatant, waiting_for_intentions: false)
  end
end
