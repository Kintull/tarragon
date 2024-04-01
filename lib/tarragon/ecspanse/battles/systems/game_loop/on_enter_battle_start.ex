defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnEnterBattleStart do
  @moduledoc """
  Current does nothing but transition to decision phase
  """

  use Ecspanse.System,
    event_subscriptions: [EcspanseStateMachine.Events.StateChanged]

  def run(
        %EcspanseStateMachine.Events.StateChanged{entity_id: entity_id, to: "Battle Start"},
        _frame
      ) do
    with {:ok, [first_exit, _]} <-
           EcspanseStateMachine.fetch_state_exits_to(entity_id, "Battle Start") do
      EcspanseStateMachine.change_state(entity_id, "Battle Start", first_exit)
    end
  end

  def run(_, _), do: :ok
end
