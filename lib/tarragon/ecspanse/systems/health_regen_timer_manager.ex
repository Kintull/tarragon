defmodule Tarragon.Ecspanse.Systems.HealthRegenTimerManager do
  @moduledoc """
  Listens for HealthChanged events and pauses or unpauses the HealthRegenTimer
  depending on health
  """
  alias Tarragon.Ecspanse.Events
  alias Tarragon.Ecspanse.Components

  use Ecspanse.System,
    lock_components: [Components.Health, Components.HealthRegenTimer],
    event_subscriptions: [Events.HealthChanged]

  def run(%Events.HealthChanged{entity_id: entity_id}, _frame) do
    with {:ok, entity} <- Ecspanse.Query.fetch_entity(entity_id),
         {:ok, {health, regen_timer}} <-
           Ecspanse.Query.fetch_components(
             entity,
             {Components.Health, Components.HealthRegenTimer}
           ) do
      maybe_update_timer_paused(regen_timer, health)
    end
  end

  defp maybe_update_timer_paused(regen_timer, health) when regen_timer.paused do
    if health.current < health.max do
      Ecspanse.Command.update_component!(regen_timer, paused: false)
    end
  end

  defp maybe_update_timer_paused(regen_timer, health) do
    if health.current == health.max do
      Ecspanse.Command.update_component!(regen_timer, paused: true)
    end
  end
end
