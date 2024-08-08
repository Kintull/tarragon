defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnExitDecisionsPhase do
  @moduledoc """
  *clear waiting for intentions
  * despawn available actions
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants

  use GameLoopConstants

  require Logger

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @from_state @state_names.decisions_phase

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, from: @from_state},
        _frame
      ) do
    Logger.debug("OnExitDecisionsPhase #{entity_id}")

    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      living_combatants = Entities.BattleEntity.list_living_combatants(battle_entity)

      living_combatants
      |> Enum.each(fn ce ->
        clear_waiting_for_intentions(ce)
      end)
    end
  end

  def run(_, _), do: :ok

  defp clear_waiting_for_intentions(%Ecspanse.Entity{} = combatant_entity) do
    {:ok, combatant} = Components.Combatant.fetch(combatant_entity)
    Ecspanse.Command.update_component!(combatant, waiting_for_intentions: false)
  end
end
