defmodule Tarragon.Systems.HealthPointIncrementor do
  @moduledoc """
  Removes the IsDamaged tag from entities that have reached their max health points.
  """
  import Tarragon.Systems.SystemHelpers

  alias Tarragon.Components.HealthIncrementTarget
  alias Tarragon.Components.HealthMaxPoints
  alias Tarragon.Components.HealthIncrementPoints
  alias Tarragon.Components.HealthPoints

  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    # System logic

    HealthIncrementTarget.get_all()
    |> where_entity_has(HealthIncrementPoints)
    |> where_target_has_health()
    |> Enum.each(&update_status/1)

    :ok
  end

  def where_target_has_health(target_tuples) do
    Enum.filter(target_tuples, fn {_entity, target} ->
      entity_has?(target, HealthPoints) and entity_has?(target, HealthMaxPoints)
    end)
  end

  defp update_status({entity, target}) do
    increment_points = HealthIncrementPoints.get(entity)
    points = HealthPoints.get(target)
    max_points = HealthMaxPoints.get(target)

    new_points = max(min(points + increment_points, max_points), 0)

    upsert(target, HealthPoints, new_points)
    HealthIncrementPoints.remove(entity)
    HealthIncrementTarget.remove(entity)
  end
end
