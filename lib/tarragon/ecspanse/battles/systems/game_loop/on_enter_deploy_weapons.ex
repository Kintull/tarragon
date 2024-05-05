defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterDeployWeapons do
  @moduledoc """
  * Executes scheduled movement actions
  """
  alias Tarragon.Ecspanse.Withables
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  @to_state @state_names.deploy_weapons

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    with {:ok, battle_entity} <- Ecspanse.Entity.fetch(entity_id) do
      scheduled_action_entities =
        Lookup.list_descendants(battle_entity, Components.ScheduledAction)
        |> Enum.filter(&Ecspanse.Query.has_component?(&1, Components.Actions.Weapon.DeployWeapon))

      if Enum.any?(scheduled_action_entities) do
        scheduled_action_entities
        |> Enum.map(&(Lookup.fetch_parent(&1, Components.Combatant) |> Withables.val_or_nil()))
        |> Enum.map(&(Components.MainWeapon.fetch(&1) |> Withables.val_or_nil()))
        |> Enum.map(&{&1, [deployed: true, encumberance: &1.deployed_encumberance]})
        |> Ecspanse.Command.update_components!()

        Ecspanse.Command.despawn_entities!(scheduled_action_entities)
      else
        EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
      end
    end
  end

  def run(_, _), do: :ok
end
