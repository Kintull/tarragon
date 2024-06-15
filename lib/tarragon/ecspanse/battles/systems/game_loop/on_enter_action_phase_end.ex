defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterActionPhaseEnd do
  @moduledoc """
  Changes to the battle end state if the battle is over.
  Otherwise changes the state to decision_phase
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  require Logger

  @to_state @state_names.action_phase_end

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    Logger.debug("OnEnterActionPhaseEnd #{entity_id}")

    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      remove_effects(battle_entity)

      case is_battle_over?(battle_entity) do
        true ->
          EcspanseStateMachine.transition(battle_entity.id, @to_state, "Battle End")

        false ->
          EcspanseStateMachine.transition(battle_entity.id, @to_state, "Decisions Phase")
      end
    end
  end

  def run(_, _), do: :ok

  defp remove_dodging(battle_entity) do
    Lookup.list_descendants(battle_entity, Components.Combatant)
    |> Enum.filter(&Ecspanse.Query.has_component?(&1, Components.Effects.Dodging))
    |> Enum.map(fn ce ->
      with {:ok, dodging} <- Components.Effects.Dodging.fetch(ce),
           do: dodging
    end)
    |> Ecspanse.Command.remove_components!()
  end

  defp remove_obscured(battle_entity) do
    Lookup.list_descendants(battle_entity, Components.Combatant)
    |> Enum.filter(&Ecspanse.Query.has_component?(&1, Components.Effects.Obscured))
    |> Enum.map(&(Components.Effects.Obscured.fetch(&1) |> Withables.val_or_nil()))
    |> Ecspanse.Command.remove_components!()
  end

  defp remove_effects(battle_entity) do
    remove_dodging(battle_entity)
    remove_obscured(battle_entity)
  end

  defp is_battle_over?(battle_entity) do
    with {:ok, battle_component} <- Components.Battle.fetch(battle_entity) do
      unless battle_component.is_completed do
        living_combatants = Entities.Battle.list_living_combatants(battle_entity)

        max_turns_exceeded = battle_component.turn >= battle_component.max_turns

        case {living_combatants, max_turns_exceeded} do
          {[], _} -> true
          {[_winner], _} -> true
          {_, true} -> true
          _ -> false
        end
      end
    end
  end
end
