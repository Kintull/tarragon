defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterBulletsImpact do
  @moduledoc """
  Current does nothing but transition to decision phase
  """
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.GameLoopConstants

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  require Logger

  @to_state @state_names.bullets_impact

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    Logger.debug("OnEnterBulletsImpact #{entity_id}")

    Components.Bullet.list()
    |> Enum.reduce(%{}, fn bullet_component, acc -> accumulate_damages(bullet_component, acc) end)
    |> Enum.map(fn {health, damage} ->
      {health, current: max(health.current - damage, 0)}
    end)
    |> Ecspanse.Command.update_components!()

    Components.Bullet.list()
    |> Enum.map(&Ecspanse.Query.get_component_entity/1)
    |> Ecspanse.Command.despawn_entities!()

    EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
  end

  def run(_, _), do: :ok

  defp accumulate_damages(bullet_component, damage_by_health) do
    IO.inspect(bullet_component.target_entity_id)

    with {:ok, target_entity} <- Ecspanse.Entity.fetch(bullet_component.target_entity_id),
         {:ok, health} <- Components.Health.fetch(target_entity) do
      damage = Map.get(damage_by_health, health, 0) + bullet_component.damage
      Map.put(damage_by_health, health, damage)
    end
  end
end
