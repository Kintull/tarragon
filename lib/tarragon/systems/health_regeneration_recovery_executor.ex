defmodule Tarragon.Systems.HealthRegenerationRecoveryExecutor do
  @moduledoc """
  """
  alias Tarragon.Components.HealthIncrementTarget
  alias Tarragon.Components.HealthIncrementPoints
  alias Tarragon.Components.HealthRegenerationScheduledRecovery
  import Tarragon.Systems.SystemHelpers

  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    # System logic

    HealthRegenerationScheduledRecovery.get_all()
    |> when_is_before(DateTime.utc_now())
    |> convert_to_health_increment_points()

    :ok
  end

  defp convert_to_health_increment_points(scheduled_recoveries)
       when is_list(scheduled_recoveries) do
    Enum.each(scheduled_recoveries, &convert_to_health_increment_points/1)
  end

  defp convert_to_health_increment_points({entity, _dt}) do
    HealthRegenerationScheduledRecovery.remove(entity)
    hip_id = Ecto.UUID.generate()
    HealthIncrementPoints.add(hip_id, 1)
    HealthIncrementTarget.add(hip_id, entity)
  end
end
