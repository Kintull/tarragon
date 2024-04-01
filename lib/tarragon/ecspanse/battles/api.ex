defmodule Tarragon.Ecspanse.Battles.Api do
  @moduledoc """
  Methods to be used by systems outside of the ecspanse battle framework.
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Events
  alias Tarragon.Ecspanse.Battles.Projections

  def battle_exists?(battle_entity_id) do
    with {:ok, entity} <- Ecspanse.Entity.fetch(battle_entity_id),
         {:ok, _battle} <- Components.Battle.fetch(entity) do
      true
    else
      _ -> false
    end
  end

  @spec cancel_scheduled_action(Ecspanse.Entity.id()) :: :ok
  def cancel_scheduled_action(scheduled_action_entity_id) do
    Ecspanse.event(
      {Events.CancelScheduledAction, [scheduled_action_entity_id: scheduled_action_entity_id]}
    )
  end

  @spec list_battles() :: list(struct())
  @doc """
  returns a list of entities for battles
  """
  def list_battles() do
    Projections.Battle.project_battles()
  end

  @spec list_battle(String.t()) :: struct()
  def list_battle(battle_entity_id) do
    Projections.Battle.project_battle(battle_entity_id)
  end

  @spec schedule_available_action(Ecspanse.Entity.id()) :: :ok
  def lock_intentions(combatant_entity_id) do
    Ecspanse.event({Events.LockIntentions, [combatant_entity_id: combatant_entity_id]})
  end

  @spec schedule_available_action(Ecspanse.Entity.id()) :: :ok
  def schedule_available_action(available_action_entity_id) do
    Ecspanse.event(
      {Events.ScheduleAvailableAction, [available_action_entity_id: available_action_entity_id]}
    )
  end

  def spawn_battle() do
    Ecspanse.event({Events.SpawnBattleRequest, []})
  end
end
