defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnStateChange do
  @moduledoc """
  """

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  require Logger

  def run(
        %EcspanseStateMachine.Events.StateChanged{
          entity_id: entity_id,
          to: to_state
        },
        _frame
      ) do
    Logger.debug("OnStateChange #{entity_id} #{to_state}")

    :ok
  end

#  def increment_turn_counter(battle_entity) do
#    with {:ok, battle_component} <- Components.Battle.fetch(battle_entity) do
#      Ecspanse.Command.update_component!(battle_component,
#        turn: battle_component.turn + 1
#      )
#    end
#  end
end
