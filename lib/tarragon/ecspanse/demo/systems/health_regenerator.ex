defmodule Tarragon.Ecspanse.Demo.Systems.HealthRegenerator do
  @moduledoc """
  Listens for ticks from the HealthRegenTimer and increases health by 1
  """
  alias Tarragon.Ecspanse.Demo.Events.HealthRegenTimerElapsed
  alias Tarragon.Ecspanse.Demo.Events
  alias Tarragon.Ecspanse.Demo.Components

  use Ecspanse.System,
    lock_components: [Components.Health],
    event_subscriptions: [Events.HealthRegenTimerElapsed]

  def run(%HealthRegenTimerElapsed{entity_id: entity_id}, _frame) do
    with {:ok, entity} <- Ecspanse.Query.fetch_entity(entity_id),
         {:ok, health} <-
           Ecspanse.Query.fetch_component(entity, Components.Health) do
      if health.current + 1 <= health.max do
        Ecspanse.Command.update_component!(health, current: health.current + 1)
        Ecspanse.event({Events.HealthChanged, entity_id: entity_id})
      end
    end
  end
end
