defmodule Tarragon.Systems.DamageOverTimePointLossExecutor do
  @moduledoc """
  Documentation for DamageOverTimePointLossExecutor system.
  """
  @behaviour ECSx.System

  alias Tarragon.Components.HealthIncrementTarget
  alias Tarragon.Components.DamageOverTimeTarget
  alias Tarragon.Components.HealthIncrementPoints
  alias Tarragon.Components.DamageOverTimeScheduledPointLoss
  import Tarragon.Systems.SystemHelpers

  @impl ECSx.System
  def run do
    # System logic
    DamageOverTimeScheduledPointLoss.get_all()
    |> when_is_before(DateTime.utc_now())
    |> where_entity_has(DamageOverTimeTarget)
    |> convert_to_health_increment_points

    :ok
  end

  defp convert_to_health_increment_points(scheduled_tuple) do
    Enum.each(scheduled_tuple, fn {entity, _dt} ->
      target = DamageOverTimeTarget.get(entity)
      DamageOverTimeScheduledPointLoss.remove(entity)

      hip_id = Ecto.UUID.generate()
      HealthIncrementPoints.add(hip_id, -1)
      HealthIncrementTarget.add(hip_id, target)
    end)
  end
end
