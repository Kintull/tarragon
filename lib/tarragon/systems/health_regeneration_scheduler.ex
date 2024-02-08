defmodule Tarragon.Systems.HealthRegenerationScheduler do
  @moduledoc """
  Tags IsDamaged entities with a HealthPointRecovery component.
  """

  alias Tarragon.Components.HealthRegenerationRateInMs
  alias Tarragon.Components.HealthRegenerationScheduledRecovery
  import Tarragon.Systems.SystemHelpers

  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    # System logic

    Tarragon.EcsxFactories.Health.get_all_injured()
    |> Enum.map(& &1.entity)
    |> where_entity_has(HealthRegenerationRateInMs)
    |> where_entity_is_missing(HealthRegenerationScheduledRecovery)
    |> add_scheduled_recoveries()

    :ok
  end

  defp add_scheduled_recoveries(entities) do
    Enum.each(entities, &add_scheduled_recovery/1)
  end

  defp add_scheduled_recovery(entity) do
    milliseconds = HealthRegenerationRateInMs.get(entity)

    add_point_dt =
      DateTime.add(DateTime.utc_now(), milliseconds, :millisecond)

    HealthRegenerationScheduledRecovery.add(entity, add_point_dt)
  end
end
