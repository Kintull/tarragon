defmodule Tarragon.Systems.HealthRegenerationStatusUpdater do
  @moduledoc """
  Updates the status of the Health Regeneration System
  """
  alias Tarragon.Components.HealthRegenerationStatus
  alias Tarragon.Components.HealthRegenerationScheduledRecovery
  alias Tarragon.Components.HealthRegenerationRateInMs
  require Tarragon.Components.HealthRegenerationStatus
  import Tarragon.Systems.SystemHelpers

  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    # System logic

    group_map =
      HealthRegenerationRateInMs.get_all()
      |> Enum.group_by(fn {entity, _rate} ->
        HealthRegenerationScheduledRecovery.exists?(entity)
      end)

    Map.get(group_map, true, [])
    |> set_status_to_regenerating()

    Map.get(group_map, false, [])
    |> set_status_to_idle()

    :ok
  end

  defp set_status_to_idle(evtuples) do
    Enum.each(evtuples, fn {entity, _dt} ->
      upsert(entity, HealthRegenerationStatus, HealthRegenerationStatus.idle())
    end)
  end

  defp set_status_to_regenerating(evtuples) do
    Enum.each(evtuples, fn {entity, _dt} ->
      upsert(entity, HealthRegenerationStatus, HealthRegenerationStatus.regenerating())
    end)
  end
end
