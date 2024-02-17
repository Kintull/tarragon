defmodule Tarragon.Ecspanse.Demo.Systems.EnergyRegenTimerManager do
  @moduledoc """
  Listens for EnergyChanged events and pauses or unpauses the EnergyRegenTimer
  depending on energy
  """
  alias Tarragon.Ecspanse.Demo.Events
  alias Tarragon.Ecspanse.Demo.Components

  use Ecspanse.System,
    lock_components: [Components.Energy, Components.EnergyRegenTimer],
    event_subscriptions: [Events.EnergyChanged]

  def run(%Events.EnergyChanged{entity_id: entity_id}, _frame) do
    with {:ok, entity} <- Ecspanse.Query.fetch_entity(entity_id),
         {:ok, {energy, regen_timer}} <-
           Ecspanse.Query.fetch_components(
             entity,
             {Components.Energy, Components.EnergyRegenTimer}
           ) do
      maybe_update_timer_paused(regen_timer, energy)
    end
  end

  defp maybe_update_timer_paused(regen_timer, energy) when regen_timer.paused do
    if energy.current < energy.max do
      Ecspanse.Command.update_component!(regen_timer, paused: false)
    end
  end

  defp maybe_update_timer_paused(regen_timer, energy) do
    if energy.current == energy.max do
      Ecspanse.Command.update_component!(regen_timer, paused: true)
    end
  end
end
