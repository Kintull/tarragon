defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.MovingAnimator do
  alias Tarragon.Ecspanse.Battles.Lookup
  alias Tarragon.Ecspanse.Battles.Components

  use Ecspanse.System
  # ,
  #   lock_components: [
  #     Components.Position,
  #     Components.Animations.Moving,
  #     Components.Animations.EndPosition,
  #     Components.Animations.StartPosition
  #   ]

  def run(%Ecspanse.Frame{} = frame) do
    Components.Animations.Moving.list()
    |> Enum.each(fn moving ->
      with moving_entity <- Ecspanse.Query.get_component_entity(moving),
           {:ok, {from, to}} <-
             Ecspanse.Query.fetch_components(
               moving_entity,
               {Components.Animations.StartPosition, Components.Animations.EndPosition}
             ),
           {:ok, positioned_entity} <- Lookup.fetch_parent(moving_entity, Components.Position),
           {:ok, position} <- Components.Position.fetch(positioned_entity) do
        delta_x =
          (from.x - to.x) * frame.delta / moving.duration

        delta_y =
          (from.y - to.y) * frame.delta / moving.duration

        new_x = clamp(position.x - delta_x, from.x, to.x)
        new_y = clamp(position.y - delta_y, from.y, to.y)

        Ecspanse.Command.update_component!(position, x: new_x, y: new_y)

        if new_x == to.x and new_y == to.y do
          Ecspanse.Command.despawn_entity!(moving_entity)
        end
      end
    end)
  end

  defp clamp(value, min, max) when max < min, do: clamp(value, max, min)

  defp clamp(value, min, max) do
    cond do
      value < min -> min
      value > max -> max
      true -> value
    end
  end
end
