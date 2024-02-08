defmodule Tarragon.Systems.DamageOverTimeScheduler do
  @moduledoc """
  Documentation for DamageOverTimeScheduler system.
  """
  import Tarragon.Systems.SystemHelpers
  alias Tarragon.Components.DamageOverTimeName
  alias Tarragon.Components.HealthPoints
  alias Tarragon.Components.DamageOverTimeTarget
  alias Tarragon.Components.DamageOverTimeScheduledPointLoss
  alias Tarragon.Components.DamageOverTimeRateInMs
  alias Tarragon.Components.DamageOverTimeOccurrencesRemaining
  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    # System logic

    DamageOverTimeOccurrencesRemaining.search(0)
    |> where_entity_is_missing(DamageOverTimeScheduledPointLoss)
    |> remove

    DamageOverTimeOccurrencesRemaining.get_all()
    |> where_entity_has(DamageOverTimeTarget)
    |> where_entity_has(DamageOverTimeRateInMs)
    |> where_entity_is_missing(DamageOverTimeScheduledPointLoss)
    |> target_has_health_points
    |> schedule_point_losses()

    :ok
  end

  defp target_has_health_points(occurrences_tuples) do
    Enum.filter(occurrences_tuples, fn {entity, _} ->
      target = DamageOverTimeTarget.get(entity)
      HealthPoints.exists?(target)
    end)
  end

  defp schedule_point_losses(dot_occurrences_remaining_tuples) do
    Enum.each(dot_occurrences_remaining_tuples, fn {entity, remaining} ->
      rate_in_ms = DamageOverTimeRateInMs.get(entity)
      point_loss_dt = DateTime.add(DateTime.utc_now(), rate_in_ms, :millisecond)
      DamageOverTimeScheduledPointLoss.add(entity, point_loss_dt)
      DamageOverTimeOccurrencesRemaining.update(entity, remaining - 1)
    end)
  end

  defp remove(entities) do
    Enum.each(entities, fn entity ->
      DamageOverTimeName.remove(entity)
      DamageOverTimeOccurrencesRemaining.remove(entity)
      DamageOverTimeRateInMs.remove(entity)
      DamageOverTimeTarget.remove(entity)
    end)
  end
end
