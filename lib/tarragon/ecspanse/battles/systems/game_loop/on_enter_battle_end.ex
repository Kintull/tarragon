defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterBattleEnd do
  @moduledoc """
  Determines Winners
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.battle_end

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id),
         {:ok, battle_component} <- Components.Battle.fetch(battle_entity) do
      living_combatants = Entities.Battle.list_living_combatants(battle_entity)

      winner_combatant_entity_id =
        case living_combatants do
          [winner] -> winner.id
          _ -> nil
        end

      living_by_team =
        Enum.group_by(
          living_combatants,
          &(Lookup.fetch_parent(&1, Components.Team) |> Withables.val_or_nil()),
          & &1
        )

      winner_team_entity_id =
        case Map.keys(living_by_team) do
          [winner] -> winner.id
          _ -> nil
        end

      Ecspanse.Command.update_component!(battle_component,
        is_completed: true,
        winner_combatant_id: winner_combatant_entity_id,
        winner_team_id: winner_team_entity_id
      )
    end
  end

  def run(_, _), do: :ok
end
