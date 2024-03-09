defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterPopSmoke do
  @moduledoc """
  Current does nothing but transition to decision phase
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Entities.Battle
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Lookup

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: "Pop Smoke"},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(&Ecspanse.Query.has_component?(&1, Components.Actions.PopSmokeGrenade))

      decrement_smoke_grenade_counts(scheduled_action_entities)
      obscure_combatants(battle_entity, scheduled_action_entities)

      Ecspanse.Command.despawn_entities!(scheduled_action_entities)
    end
  end

  def run(_, _), do: :ok

  defp obscure_combatants(battle_entity, scheduled_action_entities) do
    positions =
      scheduled_action_entities
      |> Enum.map(&(Lookup.fetch_parent(&1, Components.Combatant) |> Withables.val_or_nil()))
      |> Enum.map(&(Components.Position.fetch(&1) |> Withables.val_or_nil()))
      |> Enum.map(& &1.x)

    Battle.list_living_combatants(battle_entity)
    |> Enum.map(&(Components.Position.fetch(&1) |> Withables.val_or_nil()))
    |> Enum.filter(&(&1.x in positions))
    |> Enum.map(&Ecspanse.Query.get_component_entity(&1))
    |> Enum.map(&{&1, [{Components.Effects.Obscured, []}]})
    |> Ecspanse.Command.add_components!()
  end

  defp decrement_smoke_grenade_counts(scheduled_action_entities) do
    scheduled_action_entities
    |> Enum.map(&(Lookup.fetch_parent(&1, Components.Combatant) |> Withables.val_or_nil()))
    |> Enum.map(
      &(Ecspanse.Query.fetch_component(&1, Components.GrenadePouch)
        |> Withables.val_or_nil())
    )
    |> Enum.map(&{&1, smoke: &1.smoke - 1})
    |> Ecspanse.Command.update_components!()
  end
end
