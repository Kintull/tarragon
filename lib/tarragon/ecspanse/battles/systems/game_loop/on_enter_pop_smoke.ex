defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterPopSmoke do
  @moduledoc """
  Current does nothing but transition to decision phase
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  require Logger

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.pop_smoke

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    Logger.debug("OnEnterPopSmoke #{entity_id}")

    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(
          &Ecspanse.Query.has_component?(&1, Components.Actions.Grenades.PopSmokeGrenade)
        )

      if Enum.any?(scheduled_action_entities) do
        # decrement smoke grenade counts
        scheduled_action_entities
        |> Enum.map(fn sae ->
          with {:ok, combatant_entity} <- Lookup.fetch_parent(sae, Components.Combatant),
               {:ok, smoke_grenade} = Components.SmokeGrenade.fetch(combatant_entity) do
            {smoke_grenade, [count: smoke_grenade.count - 1]}
          end
        end)
        |> Ecspanse.Command.update_components!()

        obscure_combatants(battle_entity, scheduled_action_entities)

        Ecspanse.Command.despawn_entities!(scheduled_action_entities)
      else
        EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
      end
    end
  end

  def run(_, _), do: :ok

  defp obscure_combatants(battle_entity, scheduled_action_entities) do
    positions =
      scheduled_action_entities
      |> Enum.map(&(Lookup.fetch_parent(&1, Components.Combatant) |> Withables.val_or_nil()))
      |> Enum.map(&(Components.Position.fetch(&1) |> Withables.val_or_nil()))
      |> Enum.map(& &1.x)

    Entities.BattleEntity.list_living_combatants(battle_entity)
    |> Enum.map(&(Components.Position.fetch(&1) |> Withables.val_or_nil()))
    |> Enum.filter(&(&1.x in positions))
    |> Enum.map(&Ecspanse.Query.get_component_entity(&1))
    |> Enum.map(&{&1, [{Components.Effects.Obscured, []}]})
    |> Ecspanse.Command.add_components!()
  end
end
