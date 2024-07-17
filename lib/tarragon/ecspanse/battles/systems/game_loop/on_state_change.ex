defmodule Tarragon.Ecspanse.Battles.Systems.GameLoop.OnStateChange do
  @moduledoc """
    * update timer related information
  """

  alias Tarragon.Ecspanse.Battles.Api
  alias Tarragon.Ecspanse.Battles.BotAi
  alias Tarragon.Ecspanse.Battles.Components
  alias Tarragon.Ecspanse.Battles.Components.Actions
  alias Tarragon.Ecspanse.Battles.Encumbering
  alias Tarragon.Ecspanse.Battles.Entities
  alias Tarragon.Ecspanse.Battles.GameLoopConstants
  alias Tarragon.Ecspanse.Battles.Lookup

  use GameLoopConstants

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

    with {:ok, battle_entity} <- Ecspanse.Query.fetch_entity(entity_id) do
      {:ok, state} = EcspanseStateMachine.project(battle_entity.id)
      :ok
    end
  end

#  def increment_turn_counter(battle_entity) do
#    with {:ok, battle_component} <- Components.Battle.fetch(battle_entity) do
#      Ecspanse.Command.update_component!(battle_component,
#        turn: battle_component.turn + 1
#      )
#    end
#  end
end
