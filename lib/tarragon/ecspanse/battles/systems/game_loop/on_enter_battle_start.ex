defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterBattleStart do
  @moduledoc """
  Current does nothing but transition to decision phase
  """

  alias Tarragon.Ecspanse.Battles.GameLoopConstants

  use GameLoopConstants

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  require Logger

  @to_state @state_names.battle_start

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: @to_state},
        _frame
      ) do
    Logger.debug("OnEnterBattleStart #{entity_id}")

    with {:ok, _battle_entity} <- Ecspanse.Query.fetch_entity(entity_id) do
      EcspanseStateMachine.transition_to_default_exit(entity_id, @to_state)
    end
  end

  def run(_, _), do: :ok
end
