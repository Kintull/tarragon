defmodule Tarragon.Systems.OneShotDamageExecutor do
  @moduledoc """
  Documentation for OneShotDamageExecutor system.
  """
  @behaviour ECSx.System

  import Tarragon.Systems.SystemHelpers

  alias Tarragon.Components.HealthIncrementTarget
  alias Tarragon.Components.HealthPoints
  alias Tarragon.Components.OneShotDamageTarget
  alias Tarragon.Components.OneShotDamagePoints
  alias Tarragon.Components.HealthIncrementPoints

  @impl ECSx.System
  def run do
    # System logic
    OneShotDamageTarget.get_all()
    |> where_entity_has(OneShotDamagePoints)
    |> target_has_health_points()
    |> convert_to_health_increment_points()

    :ok
  end

  defp target_has_health_points(target_tuples) do
    Enum.filter(target_tuples, fn {_, target_entity} ->
      HealthPoints.exists?(target_entity)
    end)
  end

  defp convert_to_health_increment_points(target_tuples) when is_list(target_tuples) do
    Enum.each(target_tuples, &convert_to_health_increment_points/1)
  end

  defp convert_to_health_increment_points({entity, target}) do
    points = OneShotDamagePoints.get(entity)
    OneShotDamageTarget.remove(entity)
    OneShotDamagePoints.remove(entity)

    hip_id = Ecto.UUID.generate()
    HealthIncrementPoints.add(hip_id, -1 * points)
    HealthIncrementTarget.add(hip_id, target)
  end
end
