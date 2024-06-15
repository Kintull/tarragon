defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.StateChangeInspector do
  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  require Logger

  def run(
        %EcspanseStateMachine.Events.StateChanged{
          entity_id: entity_id,
          from: from,
          to: to,
          trigger: trigger
        },
        _frame
      ) do
    Logger.debug("StateChangeInspector #{entity_id}")
    Logger.info("#{entity_id} State from '#{from}' to '#{to}' due to '#{trigger}'")
  end
end
