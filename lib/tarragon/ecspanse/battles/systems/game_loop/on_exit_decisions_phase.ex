defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnExitDecisionsPhase do
  @moduledoc """
  *clear waiting for intentions
  * despawn available actions
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @from_state @state_names.decisions_phase

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, from: @from_state},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      living_combatants = Entities.Battle.list_living_combatants(battle_entity)

      living_combatants
      |> Enum.each(fn ce ->
        clear_waiting_for_intentions(ce)
        despawn_available_actions(ce)
      end)
    end
  end

  def run(_, _), do: :ok

  defp clear_waiting_for_intentions(%Ecspanse.Entity{} = combatant_entity) do
    {:ok, combatant} = Components.Combatant.fetch(combatant_entity)
    Ecspanse.Command.update_component!(combatant, waiting_for_intentions: false)
  end

  defp despawn_available_actions(%Ecspanse.Entity{} = combatant_entity) do
    Lookup.list_children(combatant_entity, Components.AvailableAction)
    |> Ecspanse.Command.despawn_entities!()
  end
end
