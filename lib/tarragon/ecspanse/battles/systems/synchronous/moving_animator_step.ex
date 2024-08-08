defmodule Tarragon.Ecspanse.Battles.Systems.Synchronous.MovingAnimatorStep do
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

  def run(%Ecspanse.Frame{} = _frame) do
    Components.Animations.Moving.list()
    |> Enum.each(fn moving ->
      with moving_entity <- Ecspanse.Query.get_component_entity(moving),
           {:ok, {_from, to}} <-
             Ecspanse.Query.fetch_components(
               moving_entity,
               {Components.Animations.StartPosition, Components.Animations.EndPosition}
             ),
           {:ok, positioned_entity} <- Lookup.fetch_parent(moving_entity, Components.Position),
           {:ok, position} <- Components.Position.fetch(positioned_entity) do
        Ecspanse.Command.update_component!(position, x: to.x, y: to.y, z: to.z)
        Ecspanse.Command.despawn_entity!(moving_entity)
      end
    end)
  end
end
