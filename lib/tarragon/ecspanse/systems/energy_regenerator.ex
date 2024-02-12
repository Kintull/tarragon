defmodule Tarragon.Ecspanse.Systems.EnergyRegenerator do
  @moduledoc """
  Listens for ticks from the EnergyRegenTimer and increases energy by 1
  """
  alias Tarragon.Ecspanse.Events.EnergyRegenTimerElapsed
  alias Tarragon.Ecspanse.Events
  alias Tarragon.Ecspanse.Components

  use Ecspanse.System,
    lock_components: [Components.Energy],
    event_subscriptions: [Events.EnergyRegenTimerElapsed]

  def run(%EnergyRegenTimerElapsed{entity_id: entity_id}, _frame) do
    with {:ok, entity} <- Ecspanse.Query.fetch_entity(entity_id),
         {:ok, energy} <-
           Ecspanse.Query.fetch_component(entity, Components.Energy) do
      if energy.current + 1 <= energy.max do
        Ecspanse.Command.update_component!(energy, current: energy.current + 1)
        Ecspanse.event({Events.EnergyChanged, entity_id: entity_id})
      end
    end
  end
end
