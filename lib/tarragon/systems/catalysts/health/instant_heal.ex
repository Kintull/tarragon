defmodule Tarragon.Systems.Health.InstantHeal do
  @moduledoc """
  Documentation for InstantHeal system.
  """
  alias Tarragon.Components.Catalysts.InstantHeal
  alias Tarragon.Components.HealthMaxPoints
  alias Tarragon.Components.HealthPoints
  @behaviour ECSx.System

  @impl ECSx.System
  def run do
    # System logic
    InstantHeal.get_all()
    |> Enum.each(&heal_entity/1)

    :ok
  end

  defp heal_entity({entity, heal_points}) do
    points = HealthPoints.get(entity)
    max_health = HealthMaxPoints.get(entity)
    updated_health = min(points + heal_points, max_health)
    HealthPoints.update(entity, updated_health)
    InstantHeal.remove(entity)
  end
end
