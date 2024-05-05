defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterActionPhaseStart do
  @moduledoc """
  * Clear waiting for combatant intentions
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.action_phase_start

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      clear_waiting_for_intentions(battle_entity)
    end
  end

  def run(_, _), do: :ok

  def clear_waiting_for_intentions(battle_entity) do
    living_combatant_entities = Entities.Battle.list_living_combatants(battle_entity)

    # clear waiting for intentions to each combatant

    Enum.each(living_combatant_entities, fn ce ->
      {:ok, combatant} = Components.Combatant.fetch(ce)
      Ecspanse.Command.update_component!(combatant, waiting_for_intentions: false)
    end)
  end
end
